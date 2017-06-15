﻿using Microsoft.Deployment.Common.Helpers;
using Microsoft.Deployment.Tests.Actions.TestHelpers;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Deployment.Tests.Actions.AzureTests
{
    [TestClass]
    public class StreamAnalyticsTest
    {
        [TestMethod]
        public async Task CreateStreamAnalyticsJobTest()
        {
            string id = RandomGenerator.GetRandomCharacters();
            System.Diagnostics.Debug.WriteLine($"id: {id}");
            var dataStore = await TestManager.GetDataStore(true);
            dataStore.AddToDataStore("DeploymentName", $"LanceSADeployment-{id}");
            dataStore.AddToDataStore("AzureArmFile", "Service/ARM/StreamAnalytics.json");
            var payload = new JObject();
            payload.Add("name", $"LancesStreamAnalyticsJob-{id}");
            dataStore.AddToDataStore("AzureArmParameters", payload);

            var deployArmResult = await TestManager.ExecuteActionAsync(
                "Microsoft-CreateStreamAnalyticsJob", dataStore, "Microsoft-ActivityLogTemplate");
            Assert.IsTrue(deployArmResult.IsSuccess);
     
        }
    }
}