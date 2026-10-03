# Admin authentication templates

PAM, sudoers and Polkit templates that require a FIDO2 key (via `pam_u2f`)
before fingerprint or password for `sudo` and Polkit actions.

**Do not copy these files to `/etc` on their own.** `pam.d/sudo` and
`pam.d/polkit-1` use `requisite pam_u2f.so`: without the enrolled key mapping
in `/etc/security/admin-u2f-mappings`, sudo and Polkit authentication fail and
you lose admin access. Install them only from an open root shell, after
enrolling the keys, and test before closing that shell.

They are deliberately not part of `make install-etc`.
