import os

pbx_path = 'ios/Runner.xcodeproj/project.pbxproj'

with open(pbx_path, 'r') as f:
    content = f.read()

file_ref = "7D0000000000000000000002"
build_file = "7D0000000000000000000001"

content = content.replace(f'\t\t{build_file} /* GoogleService-Info.plist in Resources */,', '')
content = content.replace(f'\t\t{build_file} /* GoogleService-Info.plist in Frameworks */,', '')

if 'GoogleService-Info.plist' in content:
    lines = content.splitlines()
    final_lines = []
    in_resources_phase = False
    
    for line in lines:
        final_lines.append(line)
        if '/* Begin PBXResourcesBuildPhase section */' in line:
            in_resources_phase = True
        if in_resources_phase and 'files = (' in line:
            final_lines.append(f'\t\t\t{build_file} /* GoogleService-Info.plist in Resources */,')
            in_resources_phase = False
            
    content = "\n".join(final_lines)

with open(pbx_path, 'w') as f:
    f.write(content)
