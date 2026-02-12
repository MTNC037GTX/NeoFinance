# NeoFinance

## Overview

NeoFinance is a cross-platform personal finance and wealth management application built using Flutter.

The system provides structured financial visibility through income tracking, expense monitoring, budgeting, account management, and configurable financial goal management within a unified analytical dashboard.

Status: Completed  
Version: v1 Final  
Project Type: Academic Capstone Project  

---

## Objective

NeoFinance was developed to deliver a structured financial management system that enables users to:

- Monitor income and expenses
- Analyze cash flow performance
- Maintain budget discipline
- Track account balances
- Manage financial goals with measurable targets
- Gain actionable financial insights

The project emphasizes clarity, consistency, and data-driven financial analysis.

---

## Core Modules

### 1. Financial Dashboard

The dashboard provides a high-level financial summary including:

- Total Income
- Total Expense
- Net Cash Flow = Income - Expense
- Savings Rate = (Income - Expense) / Income

The dashboard is designed using consistent summary card patterns and structured layout hierarchy to improve financial decision visibility.

---

### 2. Account Management

- Multiple financial accounts
- Balance tracking
- Active and inactive account handling
- Liquid asset visibility
- Structured account classification

This module ensures accurate representation of financial position across accounts.

---

### 3. Transaction Management

- Income recording
- Expense recording
- Category-based classification
- Monthly filtering
- Historical transaction logs

Transactions serve as the foundation for all financial analytics within the system.

---

### 4. Budget Management

- Category-based budget allocation
- Total Budgeted
- Total Spent
- Remaining Budget = Total Budgeted - Total Spent
- Budget utilization monitoring

This module enforces spending discipline and improves financial control.

---

### 5. Financial Goal Management

NeoFinance implements a configurable financial goal system supported through administrative setup rather than fixed predefined goal categories.

This design enables:

- Flexible goal creation
- Custom financial targets
- Adjustable timelines
- Administrative configuration and oversight
- Scalable goal logic

Each goal includes:

- Target amount
- Current progress value
- Target completion date
- Status tracking

Progress Calculation:

Goal Progress = Current Value / Target Value

This architecture ensures adaptability and long-term extensibility.

---

## Technology Stack

Frontend Framework: Flutter  
Programming Language: Dart  

Backend Services:
- Firebase Authentication for secure user login and identity management
- Firebase Firestore for cloud-based NoSQL database storage
- Real-time data synchronization via Firestore

Architecture:
- Modular page-based structure
- Structured financial data modeling
- Scalable cloud-backed architecture

---

## Design Principles

- Consistent summary card UI pattern
- Structured grid layout
- Clear financial hierarchy
- Minimal visual clutter
- Scalable module-based architecture
- Focused financial metric presentation

---

## What This Project Demonstrates

- Cross-platform application development using Flutter
- Financial domain modeling
- Data-driven dashboard implementation
- Structured budgeting system design
- Configurable goal management architecture
- End-to-end academic system delivery

---

## Limitations

- No live banking API integration
- No real-time financial synchronization
- No production deployment
- Designed for academic and portfolio purposes

---

## Project Closure

NeoFinance has completed its intended lifecycle.

Scope delivered.  
Presentation completed.  
Development frozen.  

This repository is maintained as a completed academic and portfolio project.
