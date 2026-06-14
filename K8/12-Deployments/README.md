# Kubernetes Deployment Strategies: Summary

Kubernetes manages application lifecycles through distinct deployment strategies. These strategies dictate how old Pods are replaced by new versions, balancing application availability against resource consumption.

## Native Kubernetes Deployment Types

### 1. Rolling Update (Default)
* **Mechanism:** Replaces old Pods with new ones incrementally. It ensures zero downtime by maintaining a mix of old and new versions during the transition.
* **Key Configurations:** Controlled via `maxSurge` (how many Pods can exist over the desired replica count) and `maxUnavailable` (how many Pods can be offline simultaneously).
  * By default, both fields are set to 25%.
* **Trade-off:** Requires backward compatibility for database schemas and API contracts since two application versions run in parallel.

### 2. Recreate
* **Mechanism:** Terminates all existing Pods simultaneously before spinning up the new version.
* **Key Configurations:** Simple execution with no multi-version overlap.
* **Trade-off:** Guarantees application downtime from the moment old Pods stop until new Pods pass their readiness probes.

### 3. Readiness Probe -default behaviour
* Absolute Default Behavior (No Probe Defined At All). If you do not specify a readinessProbe section in your container specification 
whatsoever:Default State: Kubernetes assumes an immediate Success state as soon as the application process starts inside the container.  
The Risk: The Pod will instantly be marked Ready in the eyes of endpoints, routers, and the Deployment controller.
* ⚠️ The Strategy Impact: If you are running a RollingUpdate with no readiness probe defined, Kubernetes will
start tearing down your old version (V1) pods the millisecond your new version (V2) container processes execute—regardless 
of whether the application inside that container is actually initialized, connected to the database, or capable of serving traffic.
---

## Advanced Deployment Types
*Note: The following strategies are not handled natively by core Kubernetes deployment controllers and require external routing mechanisms (such as Service Meshes like Istio or advanced Ingress Controllers).*

* **Blue-Green Deployment**
* **Canary Deployment**

---

## Native Deployment Phasing (3 Replicas Scenario)

Below are ASCII lifecycle representations of an update from Version 1 (V1) to Version 2 (V2) given a desired state of **3 replicas**.

1. maxSurge Rounding Rule: Always Round UP
* To ensure that a deployment never accidentally bottlenecks due to a lack of new Pods, Kubernetes rounds any fractional percentage for maxSurge up to the next highest integer.

2. maxUnavailable Rounding Rule: Always Round DOWN
* To protect your application from dropping below its minimum required serving capacity, Kubernetes rounds any fractional percentage for maxUnavailable down to the next lowest integer

### Rolling Update Scenario
*Configuration assumed: `maxSurge: 1`, `maxUnavailable: 0`*
* `maxUnavailable: 0`: "You are not allowed to terminate any old Pods until a corresponding new Pod is fully created, running, and passing its readiness probes."
* * Setting maxUnavailable: 0 alongside a readiness probe provides a critical safety layer that a readiness probe alone cannot guarantee:
  * it maintains 100% of your application's serving capacity during a rollout.
  * While the readiness probe protects you from routing traffic to unhealthy new pods, maxUnavailable: 0 protects you from shrinking your existing pool of healthy pods.

```text
[Initial State]
  (V1) (V1) (V1)                        Active Replicas: 3 (V1: 3, V2: 0)

[Phase 1: Surge New Pod]
  (V1) (V1) (V1) + [V2]                 Active Replicas: 4 (V1: 3, V2: 1)
                    ^-- Provisioning

[Phase 2: Terminate One Old Pod]
  (V1) (V1) [X]    (V2)                 Active Replicas: 3 (V1: 2, V2: 1)
             ^-- Terminating

[Phase 3: Surge Second New Pod]
  (V1) (V1)        (V2) + [V2]          Active Replicas: 4 (V1: 2, V2: 2)

[Phase 4: Terminate Second Old Pod]
  (V1) [X]         (V2)  (V2)           Active Replicas: 3 (V1: 1, V2: 2)

[Phase 5: Surge Final New Pod]
  (V1)             (V2)  (V2) + [V2]    Active Replicas: 4 (V1: 1, V2: 3)

[Phase 6: Terminate Final Old Pod]
  [X]              (V2)  (V2)  (V2)     Active Replicas: 3 (V1: 0, V2: 3)

[Final State]
  (V2) (V2) (V2)                        Active Replicas: 3 (V1: 0, V2: 3)
```

# Recreate Scenario

Configuration: Destroys entire fleet before creating the new version.

```text
[Initial State]
  (V1) (V1) (V1)                        Active Replicas: 3 (V1: 3, V2: 0)

[Phase 1: Full Termination]
  [X]  [X]  [X]                         Active Replicas: 0 (DOWNTIME BEGINS)
   ^----^----^-- All pods terminating

[Phase 2: Empty State]
  [ ]  [ ]  [ ]                         Active Replicas: 0 (DOWNTIME CONTINUES)

[Phase 3: Provisioning Fleet]
  [V2] [V2] [V2]                        Active Replicas: 0 (Passing readiness probes)

[Final State]
  (V2) (V2) (V2)                        Active Replicas: 3 (V1: 0, V2: 3)
                                                           (DOWNTIME ENDS)
```









