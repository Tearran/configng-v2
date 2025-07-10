#!/usr/bin/env bash
set -euo pipefail

# Migrate .conf files from space-separated to CSV format

migrate_file() {
	local conf_file="$1"
	echo "Migrating: $conf_file"
	
	# Create backup
	cp "$conf_file" "${conf_file}.bak"
	
	# Convert space-separated fields to CSV
	for field in arch require_os require_kernel helpers options; do
		if grep -q "^${field}=" "$conf_file"; then
			current_value=$(grep "^${field}=" "$conf_file" | cut -d= -f2-)
			# Skip if already CSV format (contains commas) or is false/empty
			if [[ "$current_value" == *","* ]] || [[ -z "$current_value" ]] || [[ "$current_value" == "false" ]]; then
				continue
			fi
			# Convert spaces to commas, trim whitespace
			csv_value=$(echo "$current_value" | xargs | tr ' ' ',')
			sed -i "s|^${field}=.*|${field}=${csv_value}|" "$conf_file"
			echo "  $field: '$current_value' -> '$csv_value'"
		fi
	done
}

main() {
	echo "Converting .conf files from space-separated to CSV format..."
	echo "Backup files will be created with .bak extension."
	echo
	
	while IFS= read -r conf_file; do
		migrate_file "$conf_file"
		echo
	done < <(find src/ -name "*.conf")
	
	echo "Migration complete!"
	echo "Run validation: tools/10_validate_module.sh all"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi