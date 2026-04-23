# Diagram Syntax Patterns

Detailed Mermaid syntax patterns for all supported diagram types.

## Sequence Diagram

```mermaid
sequenceDiagram
    %% Define participants with descriptive names
    participant U as User
    participant S as System
    participant DB as Database
    
    %% Show message flow with arrows
    U->>S: Request message
    S->>DB: Query data
    DB-->>S: Return data
    S-->>U: Response message
    
    %% Show alternative flows
    alt Success condition
        U->>S: Valid request
    else Error condition
        U->>S: Invalid request
    end
```

Key syntax elements:
- `->>` Solid arrow (synchronous call)
- `-->>` Dotted arrow (response/return)
- `participant` Named actors/components
- `alt/else/end` Alternative flows
- `opt/end` Optional flows
- `loop/end` Loop constructs

## Flowchart

```mermaid
flowchart TD
    %% Basic nodes
    Start([Start Node])
    Process[Process Step]
    Decision{Decision Point}
    End([End Node])
    
    %% Connections with labels
    Start --> Process
    Process --> Decision
    Decision -->|Yes| Action1[Action if true]
    Decision -->|No| Action2[Action if false]
    Action1 --> End
    Action2 --> End
    
    %% Subgraphs for grouping
    subgraph GroupName
        A[Node A]
        B[Node B]
    end
```

Key syntax elements:
- `TD` Top-down direction (also `LR` for left-right)
- `[Text]` Rectangles
- `(Text)` Rounded rectangles
- `{Text}` Diamonds (decisions)
- `[Text]` Circles (start/end)
- `-->` Arrows with optional labels `-->|label|`
- `subgraph` Group related elements

## Entity Relationship Diagram

```mermaid
erDiagram
    %% Define entities with attributes
    USER {
        int id PK
        string email UK
        string name
        datetime created_at
    }
    
    ORDER {
        int id PK
        int user_id FK
        decimal total
    }
    
    %% Define relationships with cardinality
    USER ||--o{ ORDER : "places"
    ORDER }|--|| PAYMENT : "has"
    
    %% Relationship notation:
    %% |o--o| Zero or one
    %% ||--|| Exactly one
    %% }o--o{ Zero or many
    %% }|--|{ One or many
```

Key syntax elements:
- Entity names in caps
- Attributes with types and keys
- `PK` Primary key, `FK` Foreign key, `UK` Unique key
- Relationship lines with cardinality markers
- Relationship labels in quotes

## Class Diagram

```mermaid
classDiagram
    %% Class definition
    class ClassName {
        -privateAttribute: Type
        +publicAttribute: Type
        ~protectedMethod(): ReturnType
        +publicMethod(param: Type): ReturnType
    }
    
    %% Relationships
    Parent <|-- Child : inheritance
    Class1 --> Class2 : association
    Class1 --* Class2 : composition
    Class1 --o Class2 : aggregation
    Class1 ..|> Class2 : realization
    Class1 .. Class2 : dependency
    
    %% Annotations
    <<interface>> InterfaceName
    <<abstract>> AbstractClass
```

Key syntax elements:
- Visibility: `-` private, `+` public, `~` protected, `#` package
- Relationship arrows: `<|--` inheritance, `-->` association, etc.
- Annotations: `<<interface>>`, `<<abstract>>`
- Method parameters and return types

## C4 Component Diagram

```mermaid
C4Component
    title Component diagram for System
    
    %% People (external actors)
    Person(personAlias, "Person Label", "Person Description")
    
    %% System boundaries
    System_Boundary(systemAlias, "System Boundary Label") {
        %% Containers within system
        Container(containerAlias, "Container Label", "Technology", "Container Description")
    }
    
    %% Container boundaries
    Container_Boundary(boundaryAlias, "Boundary Label") {
        %% Components within container
        Component(componentAlias, "Component Label", "Technology", "Component Description")
    }
    
    %% External systems
    System_Ext(extSystemAlias, "External System Label", "External System Description")
    
    %% Databases
    ContainerDb(dbAlias, "Database Label", "Technology", "Database Description")
    
    %% Relationships
    personAlias --> containerAlias : "Relationship Label"  
```

Key syntax elements:
- `Person` External actors/users
- `System_Boundary` Top-level system boundaries
- `Container` Applications/services
- `Container_Boundary` Grouping containers
- `Component` Internal components/modules
- `System_Ext` External systems
- `ContainerDb` Databases
- Relationships with labels

## State Diagram

```mermaid
stateDiagram-v2
    [*] --> State1
    State1 --> State2 : Transition label
    State2 --> State3 : Another transition
    State3 --> [*]
    
    %% Composite states
    state "Composite State" as Composite {
        [*] --> SubState1
        SubState1 --> SubState2 : Transition
    }
    
    State1 --> Composite : Enter composite
    Composite --> State3 : Exit composite
```

## Gantt Chart

```mermaid
gantt
    title Project Timeline
    dateFormat  YYYY-MM-DD
    section Section Name
    Task 1          :done, des1, 2024-01-01, 2024-01-10
    Task 2          :active, des2, 2024-01-05, 2024-01-15
    Task 3          :des3, after des2, 5d
```

## Git Graph

```mermaid
gitGraph
    commit
    branch develop
    checkout develop
    commit
    commit
    checkout main
    merge develop
    commit
```

## Pie/Bar Charts

```mermaid
pie
    title Distribution
    "Category A" : 42.86
    "Category B" : 57.14

xychart-beta
    title "Bar Chart"
    x-axis ["A", "B", "C"]
    y-axis "Value"
    bar [10, 20, 30]
```