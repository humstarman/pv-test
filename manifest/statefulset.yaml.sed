apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  namespace: {{.namespace}} 
  name: {{.name2}} 
spec:
  serviceName: "{{.name2}}"
  podManagementPolicy: Parallel
  replicas: 1
  template:
    metadata:
      labels:
        component: {{.name2}}
    spec:
      terminationGracePeriodSeconds: 10
      containers:
        - name: {{.name2}}
          image: {{.image2}} 
          imagePullPolicy: {{.image.pull.policy}} 
          env:
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - containerPort: 8080 
              name: http
          livenessProbe:
            httpGet:
              path: /THPBuilder
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          volumeMounts:
            - name: host-time
              mountPath: /etc/localtime
              readOnly: true
            - name: pics 
              mountPath: {{.mount.path}} 
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
        - name: pics 
          persistentVolumeClaim:
            claimName: {{.pvc.name}} 
