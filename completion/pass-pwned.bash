# pass-pwned completion file for bash

PASSWORD_STORE_EXTENSION_COMMANDS+=(pwned)

__password_store_extension_complete_pwned() {
	COMPREPLY+=($(compgen -- ${cur}))
	_pass_complete_entries 1
}
