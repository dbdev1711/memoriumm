import os

pbx_path = 'ios/Runner.xcodeproj/project.pbxproj'
with open(pbx_path, 'r') as f:
    content = f.read()

# Neteja de referències anteriors
lines = content.splitlines()
clean_lines = [l for l in lines if 'GoogleService-Info.plist' not in l]
content = "\n".join(clean_lines)

file_ref = "7D0000000000000000000002"
build_file = "7D0000000000000000000001"

# Injecció de referències
content = content.replace('/* Begin PBXBuildFile section */', f'/* Begin PBXBuildFile section */\n\t\t{build_file} /* GoogleService-Info.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* GoogleService-Info.plist */; }};\n')
content = content.replace('/* Begin PBXFileReference section */', f'/* Begin PBXFileReference section */\n\t\t{file_ref} /* GoogleService-Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; }};\n')

# Afegir al grup principal Runner (la primera aparició de children)
content = content.replace('children = (', f'children = (\n\t\t\t{file_ref} /* GoogleService-Info.plist */,', 1)

# Afegir a la fase de Recursos (la primera aparició de files dins de PBXResourcesBuildPhase)
resources_pos = content.find('isa = PBXResourcesBuildPhase;')
files_pos = content.find('files = (', resources_pos)
if files_pos != -1:
    content = content[:files_pos + 9] + f'\n\t\t\t{build_file} /* GoogleService-Info.plist in Resources */,' + content[files_pos + 9:]

with open(pbx_path, 'w') as f:
    f.write(content)
print("✅ Projecte iOS sincronitzat amb èxit.")
