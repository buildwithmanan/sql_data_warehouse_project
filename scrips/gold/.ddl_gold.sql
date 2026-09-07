
                    ┌───────────────────┐
                    │  dim_customers    │
                    │                   │
                    │ customer_sk       │
                    │ customer_id       │
                    │ name              │
                    │ country           │
                    └─────────┬─────────┘
                              │
                              │
                              ▼
                    ┌───────────────────┐
                    │    fact_sales     │
                    │                   │
                    │ order_number      │
                    │ customer_sk       │
                    │ product_key       │
                    │ order_date        │
                    │ quantity          │
                    │ price             │
                    │ sales             │
                    └─────────┬─────────┘
                              │
                              │
                              ▼
                    ┌───────────────────┐
                    │  dim_products     │
                    │                   │
                    │ product_key       │
                    │ product_id        │
                    │ product_name      │
                    │ category          │
                    │ subcategory       │
                    └───────────────────┘
