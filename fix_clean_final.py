import os

pbx_path = 'ios/Runner.xcodeproj/project.pbxproj'
with open(pbx_path, 'r') as f:
    lines = f.readlines()

# 1. Eliminem totes les referències del fitxer de qualsevol llista de 'children' o 'files'
# Però mantenim les definicions a PBXBuildFile i PBXFileReference
clean_lines = []
for line in lines:
    if '7D0000000000000000000002 /* GoogleService-Info.plist */,' in line:
        continue
    if '7D0000000000000000000001 /* GoogleService-Info.plist in Resources */,' in line:
        continue
    clean_lines.append(line)

content = "".join(clean_lines)

file_ref = "7D0000000000000000000002"
build_file = "7D0000000000000000000001"

# 2. Injectem al grup principal Runner (busquem on hi ha l'AppDelegate.swift)
app_delegate_marker = 'AppDelegate.swift */,'
content = content.replace(app_delegate_marker, f'{app_delegate_marker}\n\t\t\t\t{file_ref} /* GoogleService-Info.plist */,')

# 3. Injectem a la fase de recursos (PBXResourcesBuildPhase)
resources_marker = '/* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = ('
content = content.replace(resources_marker, f'{resources_marker}\n\t\t\t\t{build_file} /* GoogleService-Info.plist in Resources */,')

with open(pbx_path, 'w') as f:
    f.write(content)
print("✨ Neteja i reubicació completada.")
