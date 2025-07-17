#!/bin/bash

# Create the main directory structure
mkdir -p kubernetes/{apps,infrastructure,scripts}
mkdir -p kubernetes/apps/{nginx,postgresql}
mkdir -p kubernetes/apps/nginx/{base,overlays}
mkdir -p kubernetes/apps/postgresql/{base,overlays}
mkdir -p kubernetes/apps/nginx/overlays/{aws,gcp,azure}
mkdir -p kubernetes/apps/postgresql/overlays/{aws,gcp,azure}
mkdir -p kubernetes/infrastructure/{aws,gcp,azure}

# Create Nginx base files
cat > kubernetes/apps/nginx/base/deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: nginx-config
EOF

cat > kubernetes/apps/nginx/base/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

cat > kubernetes/apps/nginx/base/configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  ENV: "production"
EOF

cat > kubernetes/apps/nginx/base/kustomization.yaml <<EOF
resources:
- deployment.yaml
- service.yaml
- configmap.yaml
EOF

# Create Nginx overlay files for AWS
cat > kubernetes/apps/nginx/overlays/aws/deployment-patch.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  template:
    spec:
      nodeSelector:
        kubernetes.io/role: worker
        topology.kubernetes.io/zone: us-west-2a
EOF

cat > kubernetes/apps/nginx/overlays/aws/ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  rules:
  - host: nginx.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

cat > kubernetes/apps/nginx/overlays/aws/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../../base
patchesStrategicMerge:
- deployment-patch.yaml
- ingress.yaml
images:
- name: nginx
  newTag: "1.25.3"
EOF

# Create Nginx overlay files for GCP
cat > kubernetes/apps/nginx/overlays/gcp/deployment-patch.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  template:
    spec:
      nodeSelector:
        cloud.google.com/gke-nodepool: default-pool
EOF

cat > kubernetes/apps/nginx/overlays/gcp/ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: gce
spec:
  rules:
  - host: nginx.example.com
    http:
      paths:
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

cat > kubernetes/apps/nginx/overlays/gcp/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../../base
patchesStrategicMerge:
- deployment-patch.yaml
- ingress.yaml
images:
- name: nginx
  newTag: "1.25.2"
EOF

# Create PostgreSQL base files
cat > kubernetes/apps/postgresql/base/statefulset.yaml <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgresql
spec:
  serviceName: postgresql
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
      - name: postgresql
        image: postgres:15
        ports:
        - containerPort: 5432
        envFrom:
        - secretRef:
            name: postgresql-secrets
        volumeMounts:
        - name: postgresql-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgresql-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
EOF

cat > kubernetes/apps/postgresql/base/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: postgresql
spec:
  selector:
    app: postgresql
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
EOF

cat > kubernetes/apps/postgresql/base/secrets.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-secrets
type: Opaque
stringData:
  POSTGRES_USER: admin
  POSTGRES_PASSWORD: change-me-please
  POSTGRES_DB: appdb
EOF

cat > kubernetes/apps/postgresql/base/pvc.yaml <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF

cat > kubernetes/apps/postgresql/base/kustomization.yaml <<EOF
resources:
- statefulset.yaml
- service.yaml
- secrets.yaml
- pvc.yaml
EOF

# Create PostgreSQL AWS overlay
cat > kubernetes/apps/postgresql/overlays/aws/storageclass-patch.yaml <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgresql
spec:
  volumeClaimTemplates:
  - metadata:
      name: postgresql-data
    spec:
      storageClassName: gp2
EOF

cat > kubernetes/apps/postgresql/overlays/aws/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../../base
patchesStrategicMerge:
- storageclass-patch.yaml
images:
- name: postgres
  newTag: "15.3"
EOF

# Create infrastructure files
cat > kubernetes/infrastructure/aws/ebs-storageclass.yaml <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
EOF

# Create deployment script
cat > kubernetes/scripts/deploy.sh <<EOF
#!/bin/bash

ENVIRONMENT=\$1
APP=\$2

if [ -z "\$ENVIRONMENT" ] || [ -z "\$APP" ]; then
  echo "Usage: \$0 <environment> <app>"
  echo "Example: \$0 aws nginx"
  exit 1
fi

kubectl apply -k apps/\$app/overlays/\$environment
EOF

chmod +x kubernetes/scripts/deploy.sh

# Create secrets script
cat > kubernetes/scripts/secrets.sh <<EOF
#!/bin/bash

# Generate random password
POSTGRES_PASSWORD=\$(openssl rand -base64 16)

# Update secrets in base directory
yq eval -i '.stringData.POSTGRES_PASSWORD = "'"\$POSTGRES_PASSWORD"'"' apps/postgresql/base/secrets.yaml

echo "PostgreSQL password updated in the secrets file"
EOF

chmod +x kubernetes/scripts/secrets.sh

echo "Kubernetes directory structure created successfully!"
echo "Remember to:"
echo "1. Review and modify all configuration files as needed"
echo "2. Run 'kubernetes/scripts/secrets.sh' to generate secure passwords"
echo "3. Use 'kubernetes/scripts/deploy.sh <environment> <app>' to deploy"
