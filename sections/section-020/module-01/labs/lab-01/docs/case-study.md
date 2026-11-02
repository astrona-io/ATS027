---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create DaemonSet `node-report` with label `app: node-report`, container `report`, BusyBox 1.37.0 and command `sh -c "sleep 3600"`. This lab has one control-plane node and one worker. Add a toleration for the control-plane NoSchedule taint so both nodes are eligible. Keep exactly one ready owned Pod on each eligible node and preserve the ordinary probe Deployment.
