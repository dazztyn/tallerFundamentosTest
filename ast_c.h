#ifndef AST_C_H
#define AST_C_H

typedef enum {
    NODE_INT,
    NODE_FLOAT,
    NODE_STRING,
    NODE_ID,
    NODE_BINOP,
    NODE_ASSIGN,
    NODE_PRINT,
    NODE_READ,
    NODE_IF,
    NODE_WHILE,
    NODE_BLOCK,
    NODE_DECL
} NodeType;

typedef struct ASTNode {
    NodeType type;
    union {
        int ival;
        float fval;
        char* sval;
        struct {
            char* op;
            struct ASTNode* left;
            struct ASTNode* right;
        } binop;
        struct {
            char* id;
            struct ASTNode* value;
        } assign;
        struct {
            struct ASTNode* cond;
            struct ASTNode* then_branch;
            struct ASTNode* else_branch;
        } ifstmt;
        struct {
            struct ASTNode* cond;
            struct ASTNode* body;
        } whilestmt;
        struct {
            struct ASTNode** stmts;
            int stmt_count;
        } block;
        struct {
            char* id;
            NodeType decl_type;
        } decl;
    };
} ASTNode;

/* Funciones */
ASTNode* make_int_node(int value);
ASTNode* make_id_node(const char* name);
ASTNode* make_binop_node(const char* op, ASTNode* left, ASTNode* right);
ASTNode* make_assign_node(const char* id, ASTNode* value);
ASTNode* make_print_node(ASTNode* expr);
ASTNode* make_decl_node(const char* id, NodeType decl_type);
ASTNode* make_if_node(ASTNode* cond, ASTNode* then_branch, ASTNode* else_branch);
ASTNode* make_while_node(ASTNode* cond, ASTNode* body);
void print_ast(ASTNode* node, int indent);

#endif
