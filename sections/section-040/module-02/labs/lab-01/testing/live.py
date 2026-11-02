claim=get('persistentvolumeclaim','probe-data')
volume=get('persistentvolume',claim['spec']['volumeName'],namespace='')
assert volume['spec']['persistentVolumeReclaimPolicy']=='Retain', 'Preserve data after claim release'
assert volume['spec']['claimRef']['uid']==claim['metadata']['uid'], 'Keep the original bound relationship'
