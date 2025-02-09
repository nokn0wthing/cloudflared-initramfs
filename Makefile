# Makefile for cloudflared initramfs boot.

export INITRAMFS = /usr/share/initramfs-tools

.PHONY: help
help:
	@echo "USAGE:"
	@echo "  make install"
	@echo "        Install cloudflared-initramfs and default configuration files."
	@echo
	@echo "  make uninstall"
	@echo "        Remove cloudflared-initramfs from initramfs."

.PHONY: root_check
root_check:
	@if ! [ "$(shell id -u)" = 0 ]; then echo "You must be root to perform this action."; exit 1; fi

.PHONY: install_dependencies_debian
install_dependencies_debian: root_check
	@curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
	@echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list
	@apt update && apt install cloudflared initramfs-tools

.PHONY: install_files
install_files:
	@install -vD initramfs/hooks "$(INITRAMFS)/hooks/cloudflared"
	@install -vD initramfs/init-bottom "$(INITRAMFS)/scripts/init-bottom/cloudflared"

.PHONY: install
install: root_check install_dependencies_debian
	@echo "Installing cloudflared-initramfs ..."
	@chmod 0755 "./scripts/build_init-premount.sh"
	@./scripts/build_init-premount.sh $@ || exit 1
	@echo "... created cloudflared init-premount file."
	+$(MAKE) install_files
	@echo "Done."

.PHONY: uninstall
uninstall: root_check
	@echo "Uninstalling cloudflared-initramfs ..."
	@rm -f "$(INITRAMFS)/hooks/cloudflared"
	@rm -f "$(INITRAMFS)/scripts/init-premount/cloudflared"
		@rm -f "$(INITRAMFS)/scripts/init-bottom/cloudflared"
	@echo "Done."

.PHONY: build_initramfs
build_initramfs: root_check
	update-initramfs -u && update-grub
