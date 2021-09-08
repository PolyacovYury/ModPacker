import os
import sys
import traceback
from collections import OrderedDict
from pathlib import Path


def make_component(parts):
    return Path(*(p[(p.index('%') + 1) if '%' in p else 0:] for p in parts)).as_posix()


def main():
    start = Path('data/pages')
    data_files = []
    mod_files = []
    components_data = OrderedDict()
    # noinspection SpellCheckingInspection
    def_data = OrderedDict((
        ('fixed', False),
        ('restart', False),
        ('disablenouninstallwarning', True),
        ('exclusive', False),
        ('dontinheritcheck', False),
        ('checkablealone', False),
        ('preview_image', ''),
        ('preview_sound', ''),
        ('dep_soft', []),
        ('dep_hard', []),
    ))
    mod_file_flags = {}
    # noinspection SpellCheckingInspection
    def_file_flags = OrderedDict((
        ('comparetimestamp', True),
        ('confirmoverwrite', False),
        ('createallsubdirs', False),
        ('deleteafterinstall', False),
        ('dontcopy', False),
        ('dontverifychecksum', False),
        ('external', False),
        ('fontisnttruetype', False),
        ('gacinstall', False),
        ('ignoreversion', True),
        ('isreadme', False),
        ('nocompression', False),
        ('noregerror', False),
        ('onlyifdestfileexists', False),
        ('onlyifdoesntexist', False),
        ('overwritereadonly', True),
        ('promptifolder', False),
        ('recursesubdirs', True),
        ('regserver', False),
        ('regtypelib', False),
        ('replacesameversion', False),
        ('restartreplace', False),
        ('setntfscompression', False),
        ('sharedfile', False),
        ('sign', False),
        ('signonce', False),
        ('skipifsourcedoesntexist', False),
        ('solidbreak', False),
        ('sortfilesbyextension', False),
        ('sortfilesbyname', False),
        ('touch', False),
        ('uninsnosharedfileprompt', False),
        ('uninsremovereadonly', True),
        ('uninsrestartdelete', False),
        ('uninsneveruninstall', False),
        ('unsetntfscompression', False),
    ))
    messages = {}
    tree = {}
    for path, sub_dirs, sub_files in os.walk(start):
        path = Path(path)
        sub_dirs.sort(key=str.lower)
        sub_files.sort(key=str.lower)
        sub = tree
        dirs = path.parts[2:]
        if not dirs:
            continue
        if dirs[-1] in ('mods', 'configs'):
            sub_dirs[:] = []
            mod_files.append(path)
            continue
        for idx, x in enumerate(dirs):
            if x not in sub:
                components_data[make_component(dirs[:idx + 1])] = def_data.copy()
                sub = sub.setdefault(x, {})
            else:
                sub = sub[x]
        for f_name in sub_files:
            f_path = (path / f_name)
            if f_path.name == 'lang.txt':
                lang_txt = f_path.read_text('windows-1251')
                lang_data = {}
                for part in lang_txt.split('[')[1:]:
                    k, v = part.split(']')
                    v = v.lstrip('\n').rstrip().replace('\n', '%n')
                    lang_k, k = k.split('.')
                    lang_data[f'{lang_k}.Component_{make_component(dirs).replace("/", "_")}_{k}'] = v
                intersection = set(lang_data).intersection(set(messages))
                if intersection:
                    raise ValueError(f'duplicate messages: {intersection}')
                messages.update(lang_data)
            elif f_path.name == 'flags.txt':
                flags_txt = f_path.read_text('windows-1251')
                flags_data = components_data[make_component(dirs)]
                for flag in filter(None, flags_txt.split()):
                    if flag not in flags_data:
                        raise ValueError(f'incorrect component flag: {flag}, must be in {list(flags_data.keys())}')
                    flags_data[flag] = True
            elif f_path.name in ('dep_soft.txt', 'dep_hard.txt'):
                components_data[make_component(dirs)][f_path.stem] = f_path.read_text('windows-1251').split()
            elif f_path.name == 'file_flags.txt':
                flags_txt = f_path.read_text('windows-1251')
                flags_data = mod_file_flags[make_component(dirs)] = def_file_flags.copy()
                for flag in filter(None, flags_txt.split()):
                    if flag not in flags_data:
                        raise ValueError(f'incorrect component flag: {flag}, must be in {list(flags_data.keys())}')
                    flags_data[flag] = True
            elif f_path.suffix == '.png':
                components_data[make_component(dirs)]['preview_image'] = str(f_path)
                data_files.append(f_path)
            elif f_path.suffix == '.mp3':
                components_data[make_component(dirs)]['preview_sound'] = str(f_path)
                data_files.append(f_path)
    with open('src_generated/files.iss', 'w', encoding='windows-1251') as f:
        if mod_files:
            f.write('[Files]\n')
            for f_path in mod_files:
                # noinspection SpellCheckingInspection
                component = make_component(f_path.parts[2:-1])
                f.write(
                    'Source: "%s\\*"; DestDir: "{app}\\%s"; Components: %s' % (
                        f_path, ('mods\\{#GameVersion}' if f_path.name == 'mods' else 'mods\\configs'), component))
                flags_data = def_file_flags.copy()
                flags_data.update(mod_file_flags.get(component, {}))
                if any(flags_data.values()):
                    f.write('; Flags: ')
                    f.write(' '.join(f for f, v in flags_data.items() if isinstance(v, bool) and v))
                f.write("; BeforeInstall: SetInstallStatus('Component_%s_name'); " % make_component(f_path.parts[2:3]))
                f.write("AfterInstall: AddInstalledFile('');\n")
    with open('src_generated/components.iss', 'w', encoding='windows-1251') as f:
        if data_files:
            f.write('[Files]\n')
            for f_path in data_files:
                # noinspection SpellCheckingInspection
                f.write(
                    f'Source: "{f_path}"; DestDir: "{f_path.parent}"; Flags: ignoreversion nocompression dontcopy;\n')
        if components_data:
            f.write('[Components]\n')
            for component in components_data:
                f.write(f'Name: {component}; ')
                f.write('Description: {cm:Component_')
                f.write(component.replace('/', '_'))
                f.write('_name};')
                if component.count('/') == 0:
                    components_data[component]['checkablealone'] = False
                flags = ' '.join(f for f, v in components_data[component].items() if isinstance(v, bool) and v)
                if flags:
                    f.write(f' Flags: {flags};')
                f.write('\n')
            f.write('[CustomMessages]\n')
            for component in components_data:
                component = component.replace('/', '_')
                for lang_txt in 'en', 'ru':
                    for k in 'name', 'desc':
                        name = f'{lang_txt}.Component_{component}_{k}'
                        if name in messages:
                            f.write(f'{name}={messages[name]}\n')
            # noinspection SpellCheckingInspection
            f.write(
                "\n[Code]\n"
                "type\n"
                " TComponentData = record\n"
                "  fixed, restart, disablenouninstallwarning, exclusive, dontinheritcheck, checkablealone: Boolean;\n"
                "  name, desc, preview_image, preview_sound: String;\n"
                "  dep_soft, dep_hard: Array of String;\n"
                " end;\n"
                "var\n"
                " ComponentIDs: Array of String;\n"
                " ComponentData: Array of TComponentData;\n"
                "<event('InitializeWizard')>\n"
                "procedure InitializeComponentIDs();\n"
                "begin\n"
                " ComponentIDs := [\n")
            for component in components_data:
                f.write(f"  '{component}'")
                if component != next(reversed(components_data)):  # components_data[-1], O(1)
                    f.write(',')
                f.write('\n')
            f.write(" ]\n SetArrayLength(ComponentData, GetArrayLength(ComponentIDs));\n")
            for (i, (component, c_flags)) in enumerate(components_data.items()):
                f.write(f" with ComponentData[{i}] do begin\n")
                for k, v in c_flags.items():
                    v = repr(v).replace('\\\\', '\\')
                    f.write(f"  {k} := {v};\n")
                for k in ('name', 'desc'):
                    if len(component.split('/')) > 1:
                        f.write(f"  {k} := CustomMessage('Component_{component.replace('/', '_')}_{k}');\n")
                    else:
                        f.write(f"  {k} := '';\n")
                f.write(' end;\n')
            f.write("end;\n")


if __name__ == '__main__':
    # noinspection PyBroadException
    try:
        main()
        sys.exit(0)
    except Exception:
        traceback.print_exc()
        sys.exit(1)
