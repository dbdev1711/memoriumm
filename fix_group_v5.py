import os

pbx_path = 'ios/Runner.xcodeproj/project.pbxproj'
with open(pbx_path, 'r') as f:
    content = f.read()

# Primer eliminem la referència del grup de Tests on s'ha posat per error
content = content.replace('\t\t\t\t\t\t7D0000000000000000000002 /* GoogleService-Info.plist */,\n', '')
content = content.replace('\t\t\t\t\t\t7D0000000000000000000001 /* GoogleService-Info.plist in Resources */,\n', '')

# Busquem el grup principal "Runner" (és el que NO té "Tests" al nom)
# El busquem per la seva estructura típica: isa = PBXGroup; children = (...); name = Runner;
target_marker = '/* Runner */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ('
if target_marker in content:
    content = content.replace(target_marker, target_marker + '\n\t\t\t\t7D0000000000000000000002 /* GoogleService-Info.plist */,')
else:
    # Si no el troba per nom, busquem la primera aparició de "children = (" que és la del grup principal
    content = content.replace('children = (', 'children = (\n\t\t\t\t7D0000000000000000000002 /* GoogleService-Info.plist */,', 1)

with open(pbx_path, 'w') as f:
    f.write(content)
print("✅ Fitxer mogut al grup Runner correctament.")
