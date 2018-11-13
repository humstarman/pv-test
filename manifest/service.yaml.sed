apiVersion: v1
kind: Service
metadata:
  namespace: {{.namespace}}
  labels:
    component: {{.name2}} 
  name: {{.name2}}
spec:
  type: ClusterIP 
  selector:
    component: {{.name2}}
  ports:
    - port: 8080
      targetPort: 8080 
      name: http 
---
apiVersion: v1
kind: Service
metadata:
  namespace: {{.namespace}}
  labels:
    component: {{.name1}} 
  name: {{.name1}}
spec:
  type: ClusterIP 
  selector:
    component: {{.name1}}
  ports:
    - port: 8080
      targetPort: 8080 
      name: http 
