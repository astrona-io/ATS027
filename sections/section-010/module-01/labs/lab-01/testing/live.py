report=get('configmap','image-report')['data']
pods=json.loads(kubectl('-n','starfleet','get','pods','-l','app=probe','-o','json'))['items']
identities={status.get('imageID') for pod in pods for status in pod.get('status',{}).get('containerStatuses',[]) if status['name']=='probe' and status.get('ready')}
assert report.get('runtimeImageID') and report['runtimeImageID'] in identities, 'Record a real ready-container image identity'
