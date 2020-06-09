#!/bin/bash

#
# Values received by this script:
# $1: {TRIGGER.STATUS} = usually either PROBLEM or RECOVERY/OK
# $2: {TRIGGER.NAME}-{ITEM.VALUE1} = whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")
# $3: {ACTION.NAME} = to assign channel what post the alert message by zabbix action name
#
alert_state="$1"
channel="$2"
message="$3"

# Change message emoji depending on the status - RECOVERY/OK, PROBLEM && everything else
recoversub='^RECOVER(Y|ED)?$'
if [[ "$alert_state" =~ ${recoversub} ]]; then
        emoji=':alert_clover:'; #recover
elif [ "$alert_state" == 'OK' ]; then
        emoji=':alert_clover:'; #ok
elif [ "$alert_state" == 'PROBLEM' ]; then
        emoji=':alert_warning:'; #problem
else
        emoji=':alert_question:'; #unexpected
fi

#
# post message layouts
# reference       : https://api.slack.com/messaging/composing/layouts
# layouts-testing : https://api.slack.com/tools/block-kit-builder
#
payload=`cat << EOS
{"blocks": [
        {
                "type": "section",
                "text": {
                                "type": "mrkdwn",
                                "text": "*zabbixhostname*"
                        }
        },
        {
                "type": "section",
                "text": {
                                "type": "plain_text",
                                "text": "${emoji}",
                                "emoji": true
                        }
        },
        {
                "type": "section",
                "text": {
                                "type": "plain_text",
                                "text": "${message}",
                                "emoji": true
                        }
        },
        {
                "type": "divider"
        }
]}
EOS`

#                                                                                              
# Slack incoming web-hook URL                                                                  
# how to get:                                                                                  
#   1. https://api.slack.com/apps : create new app                                             
#   2. input appname and select workspace                                                      
#   3. add features and functionality : incoming webhooks                                      
#   4. add new webhook to workspace : set channel                                              
# possible to add multiple webhooks for one app                                                
#                                                                                              
if [[ "$channel" == 'slack_alert_bpaws' ]]; then                                               
        url='https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxx';
elif [ "$channel" == 'slack_alert_warning_bpaws' ]; then   
        url='https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxx';
elif [ "$channel" == 'slack_alert_average_bpaws' ]; then
        url='https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxx';
elif [ "$channel" == 'slack_alert_info_bpaws' ]; then    
        url='https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxx';
else 
        url='https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxx'; # devnull channel
fi                                                                                             

curl -m 30 -x http://proxy.address:proxy.port -X POST -H 'Content-type: application/json' --data "${payload}" "${url}" -A 'zabbix-to-slackapp'

#### test command ###############################################################
# sudo bash -x zabbix_to_slackapp.sh [OK|PROBLEM|OTHER] [ACTION_NAME] [ERR_MSG] #
#################################################################################
