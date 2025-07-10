#!/usr/bin/env bash
set -euo pipefail

# Migrate .conf files from space-separated to CSV format

migrate_file() {
	local conf_file="$1"
	echo "Migrating: $conf_file"
	
	# Create backup
	cp "$conf_file" "${conf_file}.bak"
	
	local changes_made=false
	
	# Convert space-separated fields to CSV
	for field in arch require_os require_kernel helpers options; do
		if grep -q "^${field}=" "$conf_file"; then
			current_value=$(grep "^${field}=" "$conf_file" | cut -d= -f2-)
			
			# Skip if already CSV format (contains commas), is false, or empty
			if [[ "$current_value" == *","* ]] || [[ -z "$current_value" ]] || [[ "$current_value" == "false" ]]; then
				continue
			fi
			
			# Convert spaces to commas, trim whitespace
			csv_value=$(echo "$current_value" | xargs | tr ' ' ',')
			
			# Only update if there's an actual change
			if [[ "$current_value" != "$csv_value" ]]; then
				sed -i "s|^${field}=.*|${field}=${csv_value}|" "$conf_file"
				echo "  $field: '$current_value' -> '$csv_value'"
				changes_made=true
			fi
		fi
	done
	
	if [[ "$changes_made" == "false" ]]; then
		echo "  No changes needed"
		rm -f "${conf_file}.bak"  # Remove unnecessary backup
	else
		echo "  Backup created: ${conf_file}.bak"
	fi
}

main() {
	echo "Converting .conf files from space-separated to CSV format..."
	echo "This will update fields: arch, require_os, require_kernel, helpers, options"
	echo
	
	local files_processed=0
	while IFS= read -r conf_file; do
		migrate_file "$conf_file"
		files_processed=$((files_processed + 1))
		echo
	done < <(find src/ -name "*.conf")
	
	echo "Migration complete! Processed $files_processed files."
	echo "Run validation to verify: tools/10_validate_module.sh all"
	echo
	echo "To test with new CSV format, create a module with:"
	echo "  tools/start_here.sh test_csv_module"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi