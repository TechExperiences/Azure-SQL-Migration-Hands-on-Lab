# Azure-SQL-Migration-Hands-on-Lab
 
**The estimated time to complete this lab is 1 hour.**
 
**DISCLAIMER**
 
This presentation, demonstration, and demonstration model are for informational purposes only and (1) are not subject to SOC 1 and SOC 2 compliance audits, and (2) are not designed, intended, or made available as a medical device or as a substitute for professional medical advice, diagnosis, treatment or judgment. Microsoft makes no warranties, express or implied, in this presentation, demonstration, and demonstration model. Nothing in this presentation, demonstration, or demonstration model modifies any of the terms and conditions of Microsoft's written and signed agreements. This is not an offer, and applicable terms and the information provided are subject to revision and may be changed at any time by Microsoft.
 
This presentation, demonstration, and demonstration model do not grant you or your organization any license to patents, trademarks, copyrights, or other intellectual property covering the subject matter herein.
 
The information contained in this presentation, demonstration, and demonstration model represents the current view of Microsoft on the issues discussed as of the date of presentation and/or demonstration, for the duration of your access to the demonstration model. Because Microsoft must respond to changing market conditions, it should not be interpreted as a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of presentation and/or demonstration or for the duration of your access to the demonstration model.
 
No Microsoft technology, nor any of its component technologies, including the demonstration model, is intended or made available as a substitute for the professional advice, opinion, or judgment of (1) a certified financial services professional, or (2) a certified medical professional. Partners or customers are responsible for ensuring the regulatory compliance of any solution they build using Microsoft technologies.
 
**Copyright**
 
©2026 Microsoft Corporation. All rights reserved. 
 
By using this demo/lab, you agree to the following terms:
 
The technology and functionality described in this demo/lab are provided by Microsoft Corporation for the purposes of obtaining your feedback and providing you with a learning experience. You may only use the demo/lab to evaluate such technology features and functionality and to provide feedback to Microsoft. You may not use it for any other purpose. You may not modify, copy, distribute, transmit, display, perform, reproduce, publish, license, create derivative works from, transfer, or sell this demo/lab or any portion thereof.
 
COPYING OR REPRODUCTION OF THE DEMO/LAB (OR ANY PORTION OF IT) TO ANY OTHER SERVER OR LOCATION FOR FURTHER REPRODUCTION OR REDISTRIBUTION IS EXPRESSLY PROHIBITED.
 
THIS DEMO/LAB PROVIDES CERTAIN SOFTWARE TECHNOLOGY AND PRODUCT FEATURES AND FUNCTIONALITY, INCLUDING POTENTIAL NEW FEATURES AND CONCEPTS, IN A SIMULATED ENVIRONMENT WITHOUT COMPLEX SETUP OR INSTALLATION FOR THE PURPOSE DESCRIBED ABOVE. THE TECHNOLOGY AND CONCEPTS REPRESENTED IN THIS DEMO/LAB MAY NOT REPRESENT FULL FEATURE FUNCTIONALITY AND MAY NOT WORK THE WAY A FINAL VERSION WOULD WORK. WE ALSO MAY NOT RELEASE A FINAL VERSION OF SUCH FEATURES OR CONCEPTS. YOUR EXPERIENCE USING SUCH FEATURES AND FUNCTIONALITY IN A PHYSICAL ENVIRONMENT MAY ALSO BE DIFFERENT.

## Lab: Building Work IQ

## Why Work IQ?

After establishing a **unified data foundation** with **Fabric IQ** and building **intelligent agents** with **Foundry IQ**, the final challenge is bringing AI-driven decisions into the **flow of work**.

This is where **Work IQ** becomes essential.

**Work IQ** is the execution layer that brings data insights and AI reasoning directly into **Microsoft 365 workflows**.

While **Fabric IQ** creates business intelligence and **Foundry IQ** enables intelligent agents, **Work IQ** ensures that agents can:

- See the **workplace context** (emails, Teams, meetings, organizational roles)
- Make **decisions grounded in that context**
- Execute **actions directly within Microsoft 365** (assign tasks, send messages, update documents)

Building on the trusted insights from **Fabric IQ** and reasoning capabilities from **Foundry IQ**, **Work IQ** transforms AI from a **dashboard tool** into an **active workplace assistant**.

Work IQ bridges the final gap in the intelligence lifecycle:

| Layer | Purpose | Example |
|------|--------|--------|
| Data | Unified enterprise data foundation | OneLake, Lakehouse, Eventhouse |
| Intelligence | Business understanding of the data | Fabric IQ Ontology |
| Reasoning | AI agents that analyze and recommend | Foundry IQ Agents |
| Execution | In-flow actions within Microsoft 365 | Work IQ Automation |

Most AI platforms stop at **recommendations and insights**.  
Work IQ moves organizations beyond intelligence into **automated execution and policy learning**.

---

## Business Context

**What are the benefits of Work IQ and what do we want to achieve?**

Work IQ enables organizations to:

✅ **Reduce Response Time** - From hours to minutes by automating decision workflows  
✅ **Improve Customer Satisfaction** - Proactive notifications and faster issue resolution  
✅ **Eliminate Manual Handoffs** - Actions execute automatically across Microsoft 365  
✅ **Enable Predictive Operations** - Learn from patterns to prevent future issues  
✅ **Maintain Human Oversight** - Critical decisions still require approval  
✅ **Ensure Transparency** - Complete audit trail of all automated actions

---

## Architecture Overview: Understanding the Microsoft IQ Integration


![workiq architecture](/Lab/media/WorkIQArchi1.png)

The ideal scenario demonstrates how **Copilot → Work IQ → Foundry IQ → Fabric IQ** work together:

This lab demonstrates how Work IQ transforms operational disruptions into intelligent, coordinated workplace actions within Microsoft 365.

Using the Zava Retail scenario, participants experience how a modern organization evolves from disconnected workflows and manual coordination into a Frontier Organization — one that is human-led and AI-operated.

Zava operates hundreds of physical stores alongside a rapidly growing e-commerce platform. Despite significant investments in operational systems and workplace collaboration tools, store operations teams continue to face critical challenges:
- Delayed operational response during workforce disruptions
- Manual coordination across emails, calendars, and operational systems
- Limited visibility into operational ownership and business impact
- Slow approvals and inconsistent execution across teams
- No connected workflow between operational insights, decision-making, and execution

To address these challenges, Zava’s leadership adopts Work IQ to unify workplace context, intelligent coordination, approvals, and operational execution across Microsoft 365.

Throughout the lab, Ashley, a Store Manager, relies on Work IQ to coordinate operational workflows when Robin, a Store Associate, is unexpectedly out on sick leave. Instead of manually assessing impact and coordinating responses, Work IQ analyzes the disruption, recommends actions, routes approvals, and executes workflows across specialized agents and Microsoft 365 services.

![Scenerio-Demostration](./Lab/media/Scenerio-Demostration.png)

**Microsoft IQ Responsibilities:**

| IQ Layer | Responsibility | Output |
|----------|---------------|--------|
| **Fabric IQ** | Provides trusted business data and real-time signals | Inventory levels, sales velocity, risk metrics |
| **Foundry IQ** | Reasons over data and recommends intelligent actions | Action recommendations with business context |
| **Work IQ** | Executes approved actions in Microsoft 365 | Tasks assigned, emails sent, documents updated |

---

## The Challenge

During high-pressure retail events (like Holiday Sales), store managers like **Ashley** face a critical problem:

- **Inventory goes out of stock** without warning
- **Decisions come too slowly** — by the time insights arrive, customers are already frustrated
- **Actions require manual steps** — switching between systems, updating records, notifying teams
- **No visibility into who** should take action or what dependencies exist

Work IQ solves this by connecting:

| Layer | What It Does |
|-------|------------|
| **Fabric IQ** | Provides real-time inventory data and risk analysis |
| **Foundry IQ** | Reasons about the risks and recommends actions |
| **Work IQ** | Identifies Ashley in Teams, approves actions, executes in Microsoft 365 |

---

## The Scenario: Managing Workforce Disruptions at Zava

**Ashley** (Store Manager) is managing a busy store during a high-demand operational period.
She uses Microsoft 365 Copilot with Work IQ to:

1. **Ask** : “What are my priorities for today?”
2. **Understand** : Copilot identifies workforce disruptions, operational impact, and scheduling conflicts
3. **Review** : Copilot recommends actions such as reassignment, notifications, and schedule adjustments
4. **Approve** : Ashley clicks “Approve” and Work IQ coordinates the workflow
5. **Execute** : Calendars are updated, notifications are sent, responsibilities are reassigned, and operational policies are documented for future use

---

## What We Are Building Using Work IQ

In this lab, we extend the **Fabric IQ and Foundry IQ** foundation by introducing **Work IQ execution capabilities**.

The solution demonstrates how AI agents can:

- **Detect risks** using Fabric IQ data
- **Recommend actions** using Foundry IQ intelligence
- **Execute workflows** using Work IQ automation
- **Learn policies** for future prevention

---

## Personas in This Lab

| Persona | Role | Task |
|---------|------|------|
| **April** | CEO | Accountable for revenue, customer experience, and growth |
| **Rupesh** | Chief Data Officer | Responsible for data unification and governance |
| **Eva** | Data Engineer | Building the data foundation |
| **Serena** | Data Analyst | Driving insights using business language |
| **Miguel** | AI Engineer / Data Scientist | Designing intelligent agents |
| **Ashley** | Store Manager | Coordinating operational workflows and approvals |
| **Robin** | Store Associate | Whose absence triggers operational workflow disruptions |
| **Ryan** | Store Associate | Supporting reassignment activities and operational continuity |

---

## Key Concepts

### **Context-Aware Copilot**
Copilot understands:
- Who Ashley is (her role, reports, responsibilities)
- What emails/Teams messages are relevant to the decision
- Who needs to be notified (warehouse, supplier, customers)

### **Fabric IQ Integration**
Copilot queries the Fabric IQ ontology to get:
- Inventory levels (real-time)
- Sales velocity
- Supplier lead times

### **Work IQ Execution**
Approved actions are executed directly in Microsoft 365:
- Create Teams tasks
- Send Outlook emails
- Update shared documents
- Assign calendar events

### **Policy Learning**
After execution, Copilot learns:
- "Which products run out of stock most often?"
- "What threshold triggers action?"
- "Who should be notified automatically?"

These insights become **automated policies** for the next event.

---

## What This Section Demonstrates

By building the Work IQ layer in this lab, participants learn how organizations move beyond analytics and intelligence into **AI-powered automated execution**.

You will see how:

- **Fabric IQ provides trusted business intelligence**
- **Foundry IQ enables AI agents to reason and recommend**
- **Work IQ executes actions within Microsoft 365**
- **Policy learning prevents future issues automatically**

Together, **Microsoft Fabric, Fabric IQ, Foundry IQ, and Work IQ** create a single platform that connects **data, intelligence, reasoning, and automated execution** across the enterprise.

---

### [Exercise 1: Building the Work IQ Foundation](/Lab/Lab%20Building%20Work%20IQ-V2/Exercise%201%20-%20Building%20the%20Foundry%20IQ%20Foundation/Exercise1-Building%20the%20Foundry%20IQ%20Foundation.md)

Set up the Microsoft Fabric workspace, Lakehouse, and Fabric Data Agent that serve as the intelligence foundation for the Work IQ multi-agent workflow.

**Task 1.1:** User login to Microsoft Fabric \
**Task 1.2:** Set up a Fabric workspace with proper capacity \
**Task 1.3:** Building a Lakehouse for Foundry IQ \
**Task 1.4:** Loading data into Lakehouse \
**Task 1.5:** Create a data agent with a Lakehouse as the data source \
**Task 1.6:** Validate the data agent using natural language queries

### [Exercise 2: Building Intelligent Agents](/Lab/Lab%20Building%20Work%20IQ-V2/Exercise%202%20-%20Building%20Intelligent%20Agents/Exercise%202%20-%20Building%20Intelligent%20Agents.md)

Create and configure all agents required for the Work IQ multi-agent workflow — including persona instructions, tool connections, and sub-agent mappings.

**Task 2.1:** Create agent persona and system instructions \
**Task 2.2:** Implement agent Tool Calling capabilities

### [Exercise 3: Building Workflow for MultiAgent Orchestration](/Lab/Lab%20Building%20Work%20IQ-V2/Exercise%203%20-%20Building%20Workflow%20for%20MultiAgent%20Orchestration/Exercise%203%20-%20Building%20Workflow%20for%20MultiAgent%20Orchestration.md)

Wire all configured agents into a single multi-agent workflow using the YAML workflow editor in Microsoft Foundry, then publish and validate the end-to-end stockout risk scenario.

**Task 3.1:** Create the multi-agent orchestration workflow \
**Task 3.2:** Simulate Robin's sick leave in Microsoft 365

### [Exercise 4: Executing and Validating E2E WorkIQ Workflow](/Lab/Lab%20Building%20Work%20IQ/Exercise%204%20-%20Executing%20and%20Validating%20E2E%20WorkIQ%20Workflow/Exercise%204%20-%20Executing%20and%20Validating%20E2E%20WorkIQ%20Workflow.md)

This exercise is to validate WorkIQ E2E Workflow capabilities.

**Task 4.1:** Open the published workflow in Preview \
**Task 4.2:** Execute the end-to-end workflow