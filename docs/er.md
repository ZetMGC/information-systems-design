# Entity Relationship Diagram

``` mermaid
erDiagram
    TEACHER ||--o{ ASSIGNMENT : "</br>"
    GROUP   ||--o{ ASSIGNMENT : "</br>"
    SUBJECT ||--o{ ASSIGNMENT : "</br>"
    GROUP   ||--o{ STUDENT    : "</br>"

    TEACHER {
      int teacher_id PK
      string last_name
      string first_name
      string middle_name
      string phone
      int experience_years
    }

    GROUP {
      int group_id PK
      string group_code
      string specialty
      string department
    }

    SUBJECT {
      int subject_id PK
      string title
      string description
    }

    ASSIGNMENT {
      int assignment_id PK
      int teacher_id FK
      int group_id FK
      int subject_id FK
      string lesson_type
      decimal hours
      decimal hourly_rate
    }

    STUDENT {
      int student_id PK
      string last_name
      string first_name
      string middle_name
      string email
      date birth_date
      int group_id FK
    }

```
