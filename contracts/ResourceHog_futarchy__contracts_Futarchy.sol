import "PredictionMarket";

contract Futarchy
{
	enum PreCondition{None}
	enum Metric{AccountBalance}
	enum Action{Send}

	struct Proposal
	{
		// all of the *Time fields get set to 0 when they have been executed

		uint marketEvaluationTime;
		PredictionMarket acceptanceMarket;
		PredictionMarket rejectionMarket;
		bool accepted;

		uint preConditionEvaluationTime;
		PreCondition preCondition;

		uint metricStartEvaluationTime;
		uint metricEndEvaluationTime;
		Metric metric;
		uint startingAccountBalance;

		uint actionEvaluationTime;
		Action action;
		uint sendQuantity;
		address recipientAddress;
	}

	// should this be a map?
	Proposal[] public proposals;
	
	function Futarchy()
	{
		// constructor
	}

	function addProposal(uint marketEvaluationTime, uint preConditionEvaluationTime, PreCondition preCondition, uint metricStartEvaluationTime, uint metricEndEvaluationTime, Metric metric, uint actionEvaluationTime, Action action, uint sendQuantity, address recipientAddress)
		returns(uint)
	{
		if(preConditionEvaluationTime <= marketEvaluationTime)
		{
			// pre-conditions cannot be evaluated while the market is open
			throw;
		}

		if(metricEndEvaluationTime <= metricStartEvaluationTime)
		{
			throw;
		}

		PredictionMarket acceptanceMarket = new PredictionMarket(marketEvaluationTime);
		PredictionMarket rejectionMarket = new PredictionMarket(marketEvaluationTime);

		var proposal = Proposal(
			marketEvaluationTime,
			acceptanceMarket,
			rejectionMarket,
			false,

			preConditionEvaluationTime,
			preCondition,

			metricStartEvaluationTime,
			metricEndEvaluationTime,
			metric,
			0,

			actionEvaluationTime,
			action,
			sendQuantity,
			recipientAddress
		);

		return proposals.push(proposal);
	}

	function evaluateProposalMarket(uint index)
	{
		Proposal proposal = proposals[index];

		if(proposal.marketEvaluationTime == 0 || now < proposal.marketEvaluationTime)
		{
			return;
		}

		uint acceptanceOdds = proposal.acceptanceMarket.evaluateOdds();
		uint rejectionOdds = proposal.rejectionMarket.evaluateOdds();

		if(acceptanceOdds <= rejectionOdds)
		{
			proposal.acceptanceMarket.revert();
		}
		else
		{
			proposal.rejectionMarket.revert();
			proposal.accepted = true;
		}

		proposal.marketEvaluationTime = 0;
	}

	function evaluateProposalPreCondition(uint index)
	{
		Proposal proposal = proposals[index];

		if(proposal.preConditionEvaluationTime == 0 || now < proposal.preConditionEvaluationTime)
		{
			return;
		}

		bool isPreConditionMet;

		if(proposal.preCondition == PreCondition.None)
		{
			isPreConditionMet = true;
		}
		else
		{
			// support other pre-conditions in the future
			throw;
		}

		if(!isPreConditionMet)
		{
			if(proposal.accepted)
			{
				proposal.acceptanceMarket.revert();
			}
			else
			{
				proposal.rejectionMarket.revert();
			}
		}

		proposal.preConditionEvaluationTime = 0;
	}

	function evaluateProposalMetricStart(uint index)
	{
		Proposal proposal = proposals[index];

		if(proposal.metricStartEvaluationTime == 0 || now < proposal.metricStartEvaluationTime)
		{
			return;
		}

		if(proposal.metric == Metric.AccountBalance)
		{
			proposal.startingAccountBalance = this.balance;
		}
		else
		{
			// support other metrics in the future
			throw;
		}

		proposal.metricStartEvaluationTime = 0;
	}

	function evaluateProposalAction(uint index)
	{
		Proposal proposal = proposals[index];

		if(!proposal.accepted || proposal.actionEvaluationTime == 0 || now < proposal.actionEvaluationTime)
		{
			return;
		}

		if(proposal.action == Action.Send)
		{
			proposal.recipientAddress.send(proposal.sendQuantity);
		}
		else
		{
			// support other actions in the future
			throw;
		}

		proposal.actionEvaluationTime = 0;
	}

	function evaluateProposalMetricEnd(uint index)
	{
		Proposal proposal = proposals[index];

		if(proposal.metricEndEvaluationTime == 0 || now < proposal.metricEndEvaluationTime)
		{
			return;
		}

		bool isMetricMet;

		if(proposal.metric == Metric.AccountBalance)
		{
			isMetricMet = this.balance > proposal.startingAccountBalance;
		}
		else
		{
			// support other metrics in the future
			throw;
		}

		if(proposal.accepted)
		{
			if(isMetricMet)
			{
				proposal.acceptanceMarket.awardBuyers();
			}
			else
			{
				proposal.acceptanceMarket.awardSellers();
			}
		}
		else
		{
			if(isMetricMet)
			{
				proposal.rejectionMarket.awardBuyers();
			}
			else
			{
				proposal.rejectionMarket.awardSellers();
			}
		}

		proposal.metricEndEvaluationTime = 0;
	}
}
