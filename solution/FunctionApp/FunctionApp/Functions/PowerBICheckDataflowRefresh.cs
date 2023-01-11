/*-----------------------------------------------------------------------

 Copyright (c) Microsoft Corporation.
 Licensed under the MIT license.

-----------------------------------------------------------------------*/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using FunctionApp.Authentication;
using FunctionApp.DataAccess;
using FunctionApp.Models;
using FunctionApp.Models.Options;
using FunctionApp.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Management.Compute.Fluent;
using Microsoft.Azure.Management.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FunctionApp.Functions
{
    public class PowerBICheckDataflowRefresh
    {
        private readonly PowerBIService _powerBIService;
        private readonly TaskMetaDataDatabase _taskMetaDataDatabase;
        private readonly IOptions<ApplicationOptions> _options;
        private Guid ExecutionId { get; set; }

        public PowerBICheckDataflowRefresh(IOptions<ApplicationOptions> options, TaskMetaDataDatabase taskMetaDataDatabase, PowerBIService powerBIService)
        {
            _powerBIService = powerBIService;
            _taskMetaDataDatabase = taskMetaDataDatabase;
            _options = options;
        }
        [FunctionName("PowerBICheckDataflowRefresh")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            ExecutionId = context.InvocationId;

            FrameworkRunner frp = new FrameworkRunner(log, ExecutionId);
            FrameworkRunnerWorkerWithHttpRequest worker = PowerBICheckDataflowRefreshCore;
            FrameworkRunnerResult result = await frp.Invoke(req, "PowerBICheckDataflowRefresh", worker);
            if (result.Succeeded)
            {

                return new OkObjectResult(JObject.Parse(result.ReturnObject));
            }
            else
            {
                return new BadRequestObjectResult(new { Error = "Execution Failed...." });
            }


        }

        public async Task<JObject> PowerBICheckDataflowRefreshCore(HttpRequest req,
        Logging.Logging LogHelper)
        {

            string requestBody = new StreamReader(req.Body).ReadToEndAsync().Result;
            // JObject taskObject = JsonConvert.DeserializeObject<JObject>(requestBody);

            JObject taskObject = JObject.Parse(requestBody);


            string clientId = taskObject["Source"]["System"]["ClientId"].ToString();
            string secretName = taskObject["Source"]["System"]["ClientSecretName"].ToString();
            string tenantId = taskObject["Source"]["System"]["TenantId"].ToString();
            string dataflowName = taskObject["TMOptionals"]["DataflowName"].ToString();
            string workspaceId = taskObject["TMOptionals"]["WorkspaceId"].ToString();
            string keyvaultURL = taskObject["KeyVaultBaseUrl"].ToString();
            string transactionId = taskObject["TransactionId"].ToString();

            string result = await (_powerBIService.CheckDataflowRefreshStatus(clientId, secretName, tenantId, dataflowName, workspaceId, keyvaultURL, transactionId, LogHelper));

            return JObject.Parse(result);

        }

    }
}
