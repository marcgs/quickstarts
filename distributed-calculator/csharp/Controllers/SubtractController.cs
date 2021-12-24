// ------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
// ------------------------------------------------------------

using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Subtract.Models;

namespace Subtract.Controllers
{   
    [Route("[controller]")]
    [ApiController]
    public class SubtractController : ControllerBase
    {
        private readonly ILogger _logger;

        public SubtractController(ILogger<SubtractController> logger) {
            this._logger = logger;
        }

        //POST: /subtract
        [HttpPost]
        public decimal Subtract(Operands operands)
        {
            _logger.LogInformation($"Subtracting {operands.OperandTwo} from {operands.OperandOne}"); 
            return Decimal.Parse(operands.OperandOne) - Decimal.Parse(operands.OperandTwo);
        }
    }
}
