import re

# Read the current file
with open('d:/DownloadsD/EMPOWEREMNET_FARM_DB/seed_data.sql', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []

for line in lines:
    # Skip if it's not a data row
    if not line.strip().startswith("('"):
        new_lines.append(line)
        continue
    
    # Count commas to determine if we need to add columns
    comma_count = line.count(',')
    
    if comma_count == 20:  # Missing will_return and donation_interest
        # Find the is_returning_visitor value and position
        # Pattern: ..., is_returning, 'referral_source', 'age', ...
        
        # Get age bracket to determine donation_interest
        age_match = re.search(r", '(0-17|18-25|26-40|41-60|61\+)',", line)
        if age_match:
            age = age_match.group(1)
            donation = 'NULL' if age == '0-17' else "'maybe'"
        else:
            donation = "'maybe'"
        
        # Find position after is_returning_visitor (12th comma position)
        # Insert: TRUE, <donation>
        parts = line.split(',')
        
        # After 11th comma (index 11) is is_returning_visitor
        # Insert will_return and donation_interest after it
        parts.insert(12, ' TRUE')
        parts.insert(13, ' ' + donation)
        
        line = ','.join(parts)
    
    new_lines.append(line)

# Write back
with open('d:/DownloadsD/EMPOWEREMNET_FARM_DB/seed_data.sql', 'w', encoding='utf-8', newline='') as f:
    f.writelines(new_lines)

print("✅ Updated all rows successfully!")
