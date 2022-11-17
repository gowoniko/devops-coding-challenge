commit_id=`git rev-parse --short HEAD`
NEW_IMAGE="${docker_repo_uri}:${commit_id}"
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "${service}" --region "${region}")
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "${NEW_IMAGE}" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
NEW_TASK_INFO=$(aws ecs register-task-definition --region us-east-1 --cli-input-json "$NEW_TASK_DEFINTIION")
NEW_REVISION=$(echo $NEW_TASK_INFO | jq '.taskDefinition.revision')
aws ecs update-service --cluster ${cluster} --service ${service} --task-definition ${service}:${NEW_REVISION}
