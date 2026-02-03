import re

file_path = 'd:/DownloadsD/EMPOWEREMNET_FARM_DB/seed_data.sql'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
referral_sources = [
    'Word of Mouth', 'Social Media', 'Friend/Family', 'Parent', 'School', 
    'Newsletter', 'Nonprofit Partner', 'Drove By', 'Flyer/Poster', 
    'Google Search', 'Event Listing'
]

# Create a regex pattern that matches: , TRUE/FALSE, 'ReferralSource'
# We use a non-capturing group for the referral sources joined by |
params_pattern = r"(, (?:TRUE|FALSE)), ('(?:" + "|".join(referral_sources) + r")')"

for line in lines:
    # process only value lines
    if line.strip().startswith("('"):
        # Check if this line is missing the columns
        # It misses columns if it matches the pattern (Boolean followed immediately by Referral)
        match = re.search(params_pattern, line)
        if match:
            # It's a target line!
            
            # Determine donation interest based on age
            # Find age in the line
            age_match = re.search(r", '(0-17|18-25|26-40|41-60|61\+)'", line)
            donation_val = "'maybe'" # default
            if age_match:
                age = age_match.group(1)
                if age == '0-17':
                    donation_val = "NULL"
            
            # Perform substitution
            # The match has two groups: 
            # 1: ", TRUE" (or FALSE)
            # 2: "'Referral'"
            # We want to insert ", TRUE, donation_val" between them.
            
            # actually match includes the comma before boolean, so group 1 is ", TRUE"
            
            replacement = r"\1, TRUE, " + donation_val + r", \2"
            line = re.sub(params_pattern, replacement, line)
            
    new_lines.append(line)

with open(file_path, 'w', encoding='utf-8', newline='') as f:
    f.writelines(new_lines)

print("Fixed seed data.")
