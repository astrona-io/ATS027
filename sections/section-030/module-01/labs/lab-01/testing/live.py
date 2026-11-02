statuses=get('pod','shared-report')['status'].get('initContainerStatuses',[])
assert len(statuses)==1 and statuses[0].get('state',{}).get('terminated',{}).get('exitCode')==0, 'Init container must finish successfully'
