﻿using Microsoft.Deployment.Common.ActionModel;
using Microsoft.Deployment.Common.Actions;
using Microsoft.Deployment.Common.Helpers;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Deployment.Actions.AzureCustom.ActivityLogs
{
    [Export(typeof(IAction))]
    public class GetEventHubPrimaryKey : BaseAction
    {
        public override async Task<ActionResponse> ExecuteActionAsync(ActionRequest request)
        {
            var token = request.DataStore.GetJson("AzureToken", "access_token");
            var subscription = request.DataStore.GetJson("SelectedSubscription", "SubscriptionId");
            var resourceGroup = request.DataStore.GetValue("SelectedResourceGroup");
            var ehnamespace = request.DataStore.GetValue("namespace");
            var apiVersion = request.DataStore.GetValue("apiVersion");
            string uri = $"https://management.azure.com/subscriptions/{subscription}/resourceGroups/{resourceGroup}/providers/Microsoft.EventHub/namespaces/{ehnamespace}/AuthorizationRules/RootManageSharedAccessKey/listkeys?api-version={apiVersion}";

            AzureHttpClient ahc = new AzureHttpClient(token, subscription);
            HttpResponseMessage response = await ahc.ExecuteGenericRequestWithHeaderAsync(HttpMethod.Post, uri, "{}");
            if (response.IsSuccessStatusCode)
            {
                string keyString = await response.Content.ReadAsStringAsync();
                JObject keys = JsonUtility.GetJObjectFromJsonString(keyString);
                request.DataStore.AddToDataStore("policyKeys", keys);
            }
            return new ActionResponse(ActionStatus.Success);
        }
    }
}