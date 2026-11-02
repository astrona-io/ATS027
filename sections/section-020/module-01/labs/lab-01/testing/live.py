daemon=get('daemonset','node-report')
pods=json.loads(kubectl('-n','starfleet','get','pods','-l','app=node-report','-o','json'))['items']
assert len(pods)==2 and len({pod['spec']['nodeName'] for pod in pods})==2, 'Run one Pod on each eligible node'
assert all(any(owner['uid']==daemon['metadata']['uid'] and owner.get('controller') for owner in pod['metadata'].get('ownerReferences',[])) for pod in pods), 'Use DaemonSet-owned Pods'
