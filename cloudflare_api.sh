#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-08-21 15:06:10 +0100 (Fri, 21 Aug 2020)
#
#  https://github.com/HariSekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

# args: /zones | jq .

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Queries the Cloudflare API (v4)


Requires \$CLOUDFLARE_TOKEN be available in the environment, generation a token here:

https://dash.cloudflare.com/profile/api-tokens


API Reference:

https://api.cloudflare.com/


Examples:


Test your token is working:

${0##*/} /user/tokens/verify | jq .


List the currently authenticated user:

${0##*/} /user | jq .


List accounts:

${0##*/} /accounts | jq .


List currently authenticated user's account memberships and permissions:

${0##*/} /memberships | jq .


List all zones:

${0##*/} /zones | jq .


List all DNS records in a given zone (see cloudflare_dns_records.sh / cloudflare_dns_records_all_zones.sh):

${0##*/} /zones/<zone_id>/dns_records


Export your DNS records in Bind config format:

${0##*/} /zones/<zone_id>/dns_records/export


DNS analytics reports:

${0##*/} /zones/<zone_id>/dns_analytics/report
${0##*/} /zones/<zone_id>/dns_analytics/report/bytime


Details about DNSSEC status and configuration (see cloudflare_dnssec.sh for status across all zones)

${0##*/} zones/<zone_id>/dnssec


List DNS Firewall clusters for an account:

${0##*/} /accounts/<account_id>/virtual_dns


List the IPv4 and IPv6 cidr ranges for Cloudflare (see cloudflare_cidr_ranges.sh for a ready parsed example of this):

${0##*/} /ips | jq .


List custom certificates (.result.status and .result.expires_on fields may be of interest):

${0##*/} /zones/<zone_id>/custom_certificates


Gets Cloudflare zone SSL verification status for a given zone (see cloudflare_ssl_verified.sh):

${0##*/} /zones/<zone_id>/ssl/verification


Get Firewall Rules for a zone:

${0##*/} /zones/<zone_id>/firewall/rules


Get Firewall Security Events for a zone:

${0##*/} /zones/<zone_id>/security/events


List account rules lists:

${0##*/}  /accounts/<account_id>/rules/lists


List load balancer pools:

${0##*/} /user/load_balancers/pools


List load balancer monitors:

${0##*/} /user/load_balancers/monitors


List load balancers for a zone:

${0##*/}  /zones/<zone_id>/load_balancers


Get all cidr ranges owned by the account:

${0##*/} /accounts/<account_id>/addressing/prefixes


List healthchecks for a zone:

${0##*/} /zones/<zone_id>/healthchecks
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="/path [<curl_options>]"

url_base="https://api.cloudflare.com/client/v4"

check_env_defined "CLOUDFLARE_TOKEN"

help_usage "$@"

min_args 1 "$@"

# arrays can't be exported so have to pass as a string and then split to array
if [ -n "${CURL_OPTS:-}" ]; then
    read -r -a CURL_OPTS <<< "$CURL_OPTS"
else
    read -r -a CURL_OPTS <<< "-sS --fail --connect-timeout 3"
fi

url_path="$1"
shift || :

url_path="${url_path##/}"

export TOKEN="$CLOUDFLARE_TOKEN"

# need CURL_OPTS splitting, safer than eval
# shellcheck disable=SC2086
"$srcdir/curl_auth.sh" "$url_base/$url_path" "${CURL_OPTS[@]}" "$@"
