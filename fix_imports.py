import os
import re

def fix_imports(directory):
    count = 0
    package_name = 'craftconnect'
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Check if it uses AppSpacing, AppRadius, or AppDecorations
                    if re.search(r'\b(AppSpacing|AppRadius|AppDecorations)\b', content):
                        # Check if it already imports app_constants.dart
                        if 'app_constants.dart' not in content:
                            import_path = f"package:{package_name}/config/app_constants.dart"
                            
                            # Special case for config folder
                            if 'config' in root and 'app_constants.dart' not in file:
                                # If it's in config, maybe use a simpler import if they are in the same folder
                                pass

                            lines = content.splitlines()
                            # Insert after last import
                            insert_pos = 0
                            for i, line in enumerate(lines):
                                if line.strip().startswith('import '):
                                    insert_pos = i + 1
                            
                            lines.insert(insert_pos, f"import '{import_path}';")
                            new_content = '\n'.join(lines)
                            
                            with open(filepath, 'w', encoding='utf-8') as f:
                                f.write(new_content)
                            print(f"Fixed {filepath}")
                            count += 1
                except Exception as e:
                    print(f"Error fixing {filepath}: {e}")
    print(f"Total files fixed: {count}")

if __name__ == '__main__':
    fix_imports('lib')
