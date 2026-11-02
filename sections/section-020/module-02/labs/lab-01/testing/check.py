import json,subprocess

def run(*args):
    return subprocess.run(["kubectl",*args],check=True,capture_output=True,text=True,timeout=15).stdout.strip()

def get(kind,name):
    return json.loads(run("-n","starfleet","get",kind,name,"-o","json"))

def can(verb,resource,namespace,identity):
    result=subprocess.run(["kubectl","auth","can-i",verb,resource,"-n",namespace,identity],capture_output=True,text=True,timeout=15)
    assert result.returncode in (0,1) and result.stdout.strip() in ("yes","no"), "Authorization check failed"
    return result.returncode==0 and result.stdout.strip()=="yes"

job=get("job","report"); spec=job["spec"]; status=job.get("status",{})
assert spec.get("completions",1)==1 and spec.get("parallelism",1)==1 and spec["backoffLimit"]==2, "Use the required execution limits"
pod=spec["template"]["spec"]
assert pod["restartPolicy"]=="Never" and len(pod["containers"])==1, "Use one finite task container"
container=pod["containers"][0]
assert container["name"]=="report" and container["image"]=="docker.io/library/busybox:1.37.0", "Use the required task image"
assert container["command"]==["sh","-c","printf 'report-complete\\n'"], "Run the required task"
assert status.get("succeeded",0)==1 and any(c["type"]=="Complete" and c["status"]=="True" for c in status.get("conditions",[])), "Wait for successful completion"
assert "report-complete" in run("-n","starfleet","logs","job/report").splitlines(), "Verify the task log"
print("Required resource contract and behavior verified")
