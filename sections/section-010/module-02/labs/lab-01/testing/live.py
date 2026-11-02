address=get('pod','image-probe')['status']['podIP']
assert 'image-version=v1' in kubectl('-n','starfleet','exec','shuttle','--','wget','-q','-T','3','-O-','http://'+address+':8000/'), 'Serve the content from the loaded image'
