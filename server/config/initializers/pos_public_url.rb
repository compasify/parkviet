# frozen_string_literal: true

require Rails.root.join('lib/parkviet/pos_public_url').to_s

# POS_PUBLIC_BASE_URL goes into every device pairing QR, and POS_TLS_MODE says
# where TLS ends. A value a device would refuse (plain http to a public host,
# a path, credentials) or a mode that contradicts the address stops the boot
# here, in every environment, rather than surfacing as a QR nobody can pair
# with. Unset, pairing falls back to the request's own origin.
Parkviet::PosPublicUrl.configuration
