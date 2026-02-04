import os

pbx_path = 'ios/Runner.xcodeproj/project.pbxproj'

with open(pbx_path, 'r') as f:
    content = f.read()

if 'GoogleService-Info.plist' in content:
    print("✅ El fitxer ja està registrat.")
else:
    file_ref = "7D0000000000000000000002"
    build_file = "7D0000000000000000000001"

    # Injeccions
    content = content.replace('/* Begin PBXBuildFile section */', f'/* Begin PBXBuildFile section */\n\t\t{build_file} /* GoogleService-Info.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* GoogleService-Info.plist */; }};\n')
    content = content.replace('/* Begin PBXFileReference section */', f'/* Begin PBXFileReference section */\n\t\t{file_ref} /* GoogleService-Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; }};\n')
    content = content.replace('children = (', f'children = (\n\t\t\t{file_ref} /* GoogleService-Info.plist */,', 1)
    content = content.replace('files = (', f'files = (\n\t\t\t{build_file} /* GoogleService-Info.plist in Resources */,', 1)

    with open(pbx_path, 'w') as f:
        f.write(content)
    print("🚀 Operació completada. GoogleService-Info.plist injectat.")
