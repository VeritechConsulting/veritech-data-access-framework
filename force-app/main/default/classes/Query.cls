public inherited sharing class Query {
    //================================================================================
    // Enums
    //================================================================================

    public enum SortOrder {
        ASCENDING,
        DESCENDING
    }

    public enum NullsOrder {
        FIRST,
        LAST
    }

    //================================================================================
    // Constants
    //================================================================================

    @TestVisible
    private static final String DEFAULT_SELECT_FIELDS = 'Id';
    @TestVisible
    private static final SortOrder DEFAULT_ORDER_BY_DIRECTION = SortOrder.ASCENDING;
    @TestVisible
    private static final NullsOrder DEFAULT_ORDER_BY_NULLS = NullsOrder.FIRST;
    @TestVisible
    private static final Integer MAX_LIMIT = 50000;
    @TestVisible
    private static final AccessLevel DEFAULT_ACCESS_LEVEL = AccessLevel.USER_MODE;

    //================================================================================
    // Instance variables
    //================================================================================

    @TestVisible
    private Set<SObjectField> selectFields;
    @TestVisible
    private Map<SObjectField, Set<SObjectField>> lookupFields;
    @TestVisible
    private Query subselectQuery;
    @TestVisible
    private SObjectType objectType; // For regular queries
    @TestVisible
    private String subselectRelationshipName; // Only for subselect queries
    @TestVisible
    private String whereClause;
    @TestVisible
    private Map<String, Object> bindVariables;
    @TestVisible
    private List<OrderByClause> orderByClauses;
    @TestVisible
    private Integer rowLimit;
    @TestVisible
    private Boolean forUpdate;
    @TestVisible
    private Boolean allRows;
    @TestVisible
    private AccessLevel accessLevel;

    //================================================================================
    // Constructors and constructor helpers
    //================================================================================

    public Query(SObjectType objectType) {
        this.objectType = objectType;
        this.initialize();
    }

    public Query(String subselectRelationshipName) {
        this.subselectRelationshipName = subselectRelationshipName;
        this.initialize();
    }

    private void initialize() {
        this.selectFields = new Set<SObjectField>();
        this.lookupFields = new Map<SObjectField, Set<SObjectField>>();
        this.bindVariables = new Map<String, Object>();
        this.orderByClauses = new List<OrderByClause>();
        this.forUpdate = false;
        this.allRows = false;
        this.accessLevel = DEFAULT_ACCESS_LEVEL;
    }

    //================================================================================
    // Public methods
    //================================================================================

    public Query withSelectFields(Set<SObjectField> selectFields) {
        this.selectFields = selectFields;
        return this;
    }

    public Query withLookupFields(Map<SObjectField, Set<SObjectField>> lookupFields) {
        this.lookupFields = lookupFields;
        return this;
    }

    public Query withSubselectQuery(Query subselectQuery) {
        if (!subselectQuery.isSubselectQuery()) {
            throw new IllegalArgumentException(
                'This method requires a Query constructed with a subselectRelationshipName'
            );
        }

        this.subselectQuery = subselectQuery;
        return this;
    }

    public Query withWhereClause(String whereClause) {
        return this.withWhereClause(whereClause, null);
    }

    public Query withWhereClause(String whereClause, String bindVariableName, Object bindVariableValue) {
        return this.withWhereClause(whereClause, new Map<String, Object>{ bindVariableName => bindVariableValue });
    }

    public Query withWhereClause(String whereClause, Map<String, Object> bindVariables) {
        this.whereClause = whereClause;
        this.bindVariables = bindVariables;
        return this;
    }

    public Query withOrderBy(SObjectField orderByField) {
        return this.withOrderBy(new List<SObjectField>{ orderByField });
    }

    public Query withOrderBy(List<SObjectField> orderByFields) {
        List<OrderByClause> orderByClauses = new List<OrderByClause>();

        for (SObjectField orderByField : orderByFields) {
            orderByClauses.add(new OrderByClause(orderByField));
        }

        return this.withOrderBy(orderByClauses);
    }

    public Query withOrderBy(OrderByClause orderByClause) {
        return this.withOrderBy(new List<OrderByClause>{ orderByClause });
    }

    public Query withOrderBy(List<OrderByClause> orderByClauses) {
        this.orderByClauses = orderByClauses;
        return this;
    }

    public Query withLimit(Integer rowLimit) {
        if (rowLimit > MAX_LIMIT) {
            throw new IllegalArgumentException('Cannot query more than ' + MAX_LIMIT + ' records per transaction');
        }

        this.rowLimit = rowLimit;
        return this;
    }

    public Query withForUpdate() {
        if (this.allRows) {
            throw new IllegalArgumentException('Cannot use "FOR UPDATE" with "ALL ROWS"');
        }

        this.forUpdate = true;
        return this;
    }

    public Query withAllRows() {
        if (this.forUpdate) {
            throw new IllegalArgumentException('Cannot use "ALL ROWS" with "FOR UPDATE"');
        }

        this.allRows = true;
        return this;
    }

    public Query withAccessLevel(AccessLevel accessLevel) {
        this.accessLevel = accessLevel;
        return this;
    }

    public String toSOQL() {
        return this.getSelectStatement() +
            this.getSelectLookupFields() +
            this.getSubselectQuery() +
            this.getFromStatement() +
            this.getWhereStatement() +
            this.getOrderByStatement() +
            this.getLimitStatement() +
            this.getForUpdateStatement() +
            this.getAllRowsStatement();
    }

    public Map<String, Object> getBindVariables() {
        return this.bindVariables;
    }

    public AccessLevel getAccessLevel() {
        return this.accessLevel;
    }

    public Boolean isSubselectQuery() {
        return String.isNotBlank(this.subselectRelationshipName);
    }

    public Boolean isTopLevelQuery() {
        return this.objectType != null;
    }

    //================================================================================
    // Private helpers
    //================================================================================

    @TestVisible
    private String getSelectStatement() {
        if (selectFields.isEmpty()) {
            return 'SELECT ' + DEFAULT_SELECT_FIELDS;
        }

        Set<String> selectFieldsStringSet = new Set<String>();

        for (SObjectField selectField : this.selectFields) {
            selectFieldsStringSet.add(String.valueOf(selectField));
        }

        return 'SELECT ' + String.join(selectFieldsStringSet, ', ');
    }

    @TestVisible
    private String getSelectLookupFields() {
        if (this.lookupFields.isEmpty()) {
            return '';
        }

        Set<String> lookupFieldsStringSet = new Set<String>();

        for (SObjectField lookupField : this.lookupFields.keySet()) {
            String lookupFieldRelationship = String.valueOf(lookupField)
                .removeEndIgnoreCase('Id')
                .replace('__c', '__r');

            for (SObjectField childField : this.lookupFields.get(lookupField)) {
                lookupFieldsStringSet.add(lookupFieldRelationship + '.' + String.valueOf(childField));
            }
        }

        return ', ' + String.join(lookupFieldsStringSet, ', ');
    }

    @TestVisible
    private String getSubselectQuery() {
        return this.subselectQuery != null ? ', (' + this.subselectQuery.toSOQL() + ')' : '';
    }

    @TestVisible
    private String getFromStatement() {
        String fromStatement = ' FROM ';

        if (this.isTopLevelQuery()) {
            fromStatement += String.valueOf(this.objectType);
        } else if (this.isSubselectQuery()) {
            fromStatement += this.subselectRelationshipName;
        }

        return fromStatement;
    }

    @TestVisible
    private String getWhereStatement() {
        return String.isNotBlank(this.whereClause) ? ' WHERE ' + this.whereClause : '';
    }

    @TestVisible
    private String getOrderByStatement() {
        if (this.orderByClauses.isEmpty()) {
            return '';
        }

        List<String> orderByStatements = new List<String>();

        for (OrderByClause orderByClause : this.orderByClauses) {
            orderByStatements.add(
                String.format(
                    '{0} {1} NULLS {2}',
                    new List<String>{
                        String.valueOf(orderByClause.orderByField),
                        orderByClause.orderByDirection == SortOrder.ASCENDING ? 'ASC' : 'DESC',
                        orderByClause.orderByNulls.name()
                    }
                )
            );
        }

        return ' ORDER BY ' + String.join(orderByStatements, ', ');
    }

    @TestVisible
    private String getLimitStatement() {
        return this.rowLimit != null && this.rowLimit > 0 ? ' LIMIT ' + String.valueOf(this.rowLimit) : '';
    }

    @TestVisible
    private String getForUpdateStatement() {
        return this.forUpdate ? ' FOR UPDATE' : '';
    }

    @TestVisible
    private String getAllRowsStatement() {
        return this.allRows ? ' ALL ROWS' : '';
    }

    //================================================================================
    // Inner classes
    //================================================================================

    public class OrderByClause {
        @TestVisible
        private SObjectField orderByField;
        @TestVisible
        private SortOrder orderByDirection;
        @TestVisible
        private NullsOrder orderByNulls;

        public OrderByClause(SObjectField orderByField) {
            this.orderByField = orderByField;
            this.orderByDirection = DEFAULT_ORDER_BY_DIRECTION;
            this.orderByNulls = DEFAULT_ORDER_BY_NULLS;
        }

        public OrderByClause withOrderByDirection(SortOrder orderByDirection) {
            this.orderByDirection = orderByDirection;
            return this;
        }

        public OrderByClause withOrderByNulls(NullsOrder orderByNulls) {
            this.orderByNulls = orderByNulls;
            return this;
        }
    }
}