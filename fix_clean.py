import os

pbx_path = 'ios/Runner.xcodeproj/project.pbxproj'
with open(pbx_path, 'r') as f:
    lines = f.readlines()

# Eliminem ABSOLUTAMENT TOTES les línies que mencionin el fitxer
clean_lines = [l for l in lines if 'GoogleService-Info.plist' not in l]

file_ref = "7D0000000000000000000002"
build_file = "7D0000000000000000000001"

final_lines = []
for line in clean_lines:
    final_lines.append(line)
    if '/* Begin PBXBuildFile section */' in line:
        final_lines.append(f'\t\t{build_file} /* GoogleService-Info.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* GoogleService-Info.plist */; }};\n')
    elif '/* Begin PBXFileReference section */' in line:
        final_lines.append(f'\t\t{file_ref} /* GoogleService-Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; }};\n')
    elif 'children = (' in line and 'Runner' in line: # Només al grup Runner
        final_lines.append(f'\t\t\t{file_ref} /* GoogleService-Info.plist */,\n')
    elif '/* Resources */ = {' in line: # Busquem l'inici de la secció de recursos
        continue
    elif 'files = (' in line and 'Resources' in final_lines[-2]: # Seguretat per injectar a la fase de recursos
        final_lines.append(f'\t\t\t{build_file} /* GoogleService-Info.plist in Resources */,\n')

with open(pbx_path, 'w') as f:
    f.writelines(final_lines)
