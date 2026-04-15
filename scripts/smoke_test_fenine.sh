#!/bin/sh
set -eu

SAFE_L2_ADDRESS="0xF63b305B4dacDba7dc3314b8e238715E2f140492"
PROXY_FACTORY_ADDRESS="0xf4486c7e753F5E46F4c0Ef8D4266Cc53D7131020"

docker compose up -d db redis rabbitmq web indexer-worker contracts-tokens-worker scheduler nginx

docker compose run --rm indexer-worker python manage.py check_chainid_matches

docker compose run --rm indexer-worker python manage.py shell -c "from safe_transaction_service.history.models import ProxyFactory, SafeMasterCopy; safe = list(SafeMasterCopy.objects.filter(address='${SAFE_L2_ADDRESS}').values_list('address', 'initial_block_number', 'version', 'l2')); proxy = list(ProxyFactory.objects.filter(address='${PROXY_FACTORY_ADDRESS}').values_list('address', 'initial_block_number')); assert safe, 'Missing Fenine SafeL2 entry'; assert proxy, 'Missing Fenine ProxyFactory entry'; print({'safe_master_copies': safe, 'proxy_factories': proxy})"

curl -fsS http://localhost:8000/api/v1/about/
