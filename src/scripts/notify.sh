if [ -n "$SHIP_ORG" ]; then
  ACTUAL_SHIP_ORG=$SHIP_ORG
fi

if [ -n "$SHIP_ORG_PARAM" ]; then
  ACTUAL_SHIP_ORG=$SHIP_ORG_PARAM
fi

if [ -z "$ACTUAL_SHIP_ORG" ]; then
  echo "[Ship Orb]: ERROR: Ship org parameter is not set."
  exit 1
fi

if [ -z "$SHIP_COMPLETED" ]; then
  echo "[Ship Orb]: ERROR: 'completed' parameter has been overridden to a blank value"
  exit 1
fi

if [ -z "$SHIP_HOST" ]; then
  echo "[Ship Orb]: ERROR: ship_host parameter has been overridden to a blank value"
  exit 1
fi

if [ -z "$SHIP_API_KEY" ]; then
  echo "[Ship Orb]: ERROR: Ship API Key (environment variable / secret 'SHIP_API_KEY') is not set."
  exit 1
fi

if [ ! -f /tmp/SHIP_JOB_STATUS ]; then
  echo "[Ship Orb]: ERROR - Can't find file /tmp/SHIP_JOB_STATUS ."
  exit 1
fi

. "/tmp/SHIP_JOB_STATUS"

if [ -z "$CCI_STATUS" ]; then
  echo "[Ship Orb]: ERROR: CCI_STATUS env var wasn't set, even after running /tmp/SHIP_JOB_STATUS"
  exit 1
fi

if [ -n "$CIRCLE_SHA1" ]; then
  COMMIT_SHA=$CIRCLE_SHA1
else
  COMMIT_SHA="NO_COMMIT"
fi

set -euo pipefail

SHIP_COMPLETED=$SHIP_COMPLETED
PROJECT_NAME=$CIRCLE_PROJECT_REPONAME
PROJECT_ID=$CIRCLE_PROJECT_REPONAME
WORKFLOW_NAME=$CIRCLE_JOB
WORKFLOW_ID=$CIRCLE_JOB
DATE_TIME="$(date +%F)T$(date -u +%T)Z"
RUN_NUMBER=$CIRCLE_BUILD_NUM
PROVIDER_RUN_URL=$CIRCLE_BUILD_URL
CCI_STATUS=$CCI_STATUS

if [ "$SHIP_COMPLETED" = "true" ]; then
  ACTIVITY="RunCompleted"
  if [ "$CCI_STATUS" = "pass" ]; then
    CONCLUSION="Success"
  else
    CONCLUSION="Failure"
  fi
else
  ACTIVITY="RunInProgress"
  CONCLUSION="NotYetComplete"
fi

RUN_ID="$CIRCLE_WORKFLOW_ID:$ACTIVITY:$DATE_TIME"

echo "SHIP_ORG=$ACTUAL_SHIP_ORG"
echo "SHIP_HOST=$SHIP_HOST"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "PROJECT_ID=$PROJECT_ID"
echo "DATE_TIME=$DATE_TIME"
echo "ACTIVITY=$ACTIVITY"
echo "CONCLUSION=$CONCLUSION"
echo "RUN_ID=$RUN_ID"
echo "RUN_NUMBER=$RUN_NUMBER"
echo "PROVIDER_RUN_URL=$PROVIDER_RUN_URL"
echo "SHIP_COMPLETED=$SHIP_COMPLETED"
echo "CCI_STATUS=$CCI_STATUS"
echo "COMMIT_SHA=$COMMIT_SHA"
# CIRCLE_BRANCH also available but not currently used

if [ "$COMMIT_SHA" = "NO_COMMIT" ]; then
  COMMIT_BLOCK_ADDITION=""
  END_OF_RUN_BLOCK_DELIMITER=""
else
  COMMIT_BLOCK_ADDITION=$(
    cat <<-END
            "commits": [{
                "provider": "GITHUB",
                "id": "$COMMIT_SHA"
            }]
END
  )
  END_OF_RUN_BLOCK_DELIMITER=","
fi

SHIP_PROVIDER_EVENT=$(
  cat <<-END
{
    "provider": {
        "type": "CIRCLE_CI",
        "integration": {
            "name": "circleci-to-ship",
            "version": "1.0.0"
        }
    },
    "organization": {
        "name": "$ACTUAL_SHIP_ORG",
        "key": "$SHIP_API_KEY"
    },
    "providerEventType": "runEvents",
    "content": {
        "events": [
            {
                "workflow": {
                    "projectName": "$PROJECT_NAME",
                    "projectId": "$PROJECT_ID",
                    "workflowName": "$WORKFLOW_NAME",
                    "workflowId": "$WORKFLOW_ID"
                },
                "run": {
                    "id": "$RUN_ID",
                    "activity": "$ACTIVITY",
                    "conclusion": "$CONCLUSION",
                    "dateTime": "$DATE_TIME",
                    "runNumber": "$RUN_NUMBER",
                    "providerRunWebpageUrl": "$PROVIDER_RUN_URL"
                }$END_OF_RUN_BLOCK_DELIMITER
                $COMMIT_BLOCK_ADDITION
            }
        ]
    }
}
END
)

curl -X POST -H 'Content-type: application/json' --data "$SHIP_PROVIDER_EVENT" https://"$SHIP_HOST"/provider/events
