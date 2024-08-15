public inherited sharing class AggregateQuery {

    //================================================================================
    // Constants
    //================================================================================

    @TestVisible
    private static final String DEFAULT_SELECT_FIELDS = 'Id';
    @TestVisible
    private static final AccessLevel DEFAULT_ACCESS_LEVEL = AccessLevel.USER_MODE;

    //================================================================================
    // Instance variables
    //================================================================================

    @TestVisible
    private String selectStatement;
    @TestVisible
    private SObjectType objectType;
    @TestVisible
    private String whereClause;
    @TestVisible
    private Map<String, Object> bindVariables;
    @TestVisible
    private String otherStatements;
    @TestVisible
    private AccessLevel accessLevel;

    //================================================================================
    // Constructors
    //================================================================================

    public AggregateQuery(SObjectType objectType) {
        this.objectType = objectType;
    }

    //================================================================================
    // Public methods
    //================================================================================

    public AggregateQuery withSelectStatement(String selectStatement) {
        this.selectStatement = selectStatement;
        return this;
    }

    public AggregateQuery withWhereClause(String whereClause) {
        return this.withWhereClause(whereClause, null);
    }

    public AggregateQuery withWhereClause(String whereClause, String bindVariableName, Object bindVariableValue) {
        return this.withWhereClause(whereClause, new Map<String, Object>{ bindVariableName => bindVariableValue });
    }

    public AggregateQuery withWhereClause(String whereClause, Map<String, Object> bindVariables) {
        this.whereClause = whereClause;
        this.bindVariables = bindVariables;
        return this;
    }

    public AggregateQuery withOtherStatements(String otherStatements) {
        this.otherStatements = otherStatements;
        return this;
    }

    public AggregateQuery withAccessLevel(AccessLevel accessLevel) {
        this.accessLevel = accessLevel;
        return this;
    }

    public String toSOQL() {
        return this.getSelectStatement() +
            this.getFromStatement() +
            this.getWhereStatement() +
            this.getOtherStatements();
    }

    public Map<String, Object> getBindVariables() {
        return this.bindVariables;
    }

    public AccessLevel getAccessLevel() {
        return this.accessLevel ?? DEFAULT_ACCESS_LEVEL;
    }

    //================================================================================
    // Private helpers
    //================================================================================

    @TestVisible
    private String getSelectStatement() {
        String selectFields = this.selectStatement ?? DEFAULT_SELECT_FIELDS;
        return 'SELECT ' + selectFields;
    }

    @TestVisible
    private String getFromStatement() {
        return ' FROM ' + String.valueOf(this.objectType);
    }

    @TestVisible
    private String getWhereStatement() {
        return String.isNotBlank(this.whereClause) ? ' WHERE ' + this.whereClause : '';
    }

    @TestVisible
    private String getOtherStatements() {
        return String.isNotBlank(this.otherStatements) ? ' ' + this.otherStatements : '';
    }
}