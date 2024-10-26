eksctl create fargateprofile \
    --cluster doc-cluster \
    --name fargate-skills \
    --namespace skills \
    --labels app=other \
    --region ap-northeast-2