#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast_c.h"

ASTNode* make_int_node(int value) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_INT;
    node->ival = value;
    return node;
}

ASTNode* make_id_node(const char* name) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_ID;
    node->sval = strdup(name);
    return node;
}

ASTNode* make_binop_node(const char* op, ASTNode* left, ASTNode* right) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_BINOP;
    node->binop.op = strdup(op);
    node->binop.left = left;
    node->binop.right = right;
    return node;
}

ASTNode* make_assign_node(const char* id, ASTNode* value) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_ASSIGN;
    node->assign.id = strdup(id);
    node->assign.value = value;
    return node;
}

ASTNode* make_print_node(ASTNode* expr) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_PRINT;
    node->assign.value = expr;
    return node;
}

ASTNode* make_decl_node(const char* id, NodeType decl_type) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_DECL;
    node->decl.id = strdup(id);
    node->decl.decl_type = decl_type;
    return node;
}

ASTNode* make_if_node(ASTNode* cond, ASTNode* then_branch, ASTNode* else_branch) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_IF;
    node->ifstmt.cond = cond;
    node->ifstmt.then_branch = then_branch;
    node->ifstmt.else_branch = else_branch;
    return node;
}

ASTNode* make_while_node(ASTNode* cond, ASTNode* body) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = NODE_WHILE;
    node->whilestmt.cond = cond;
    node->whilestmt.body = body;
    return node;
}

void print_indent(int indent) {
    for (int i = 0; i < indent; i++) printf("  ");
}

void print_ast(ASTNode* node, int indent) {
    if (!node) return;

    print_indent(indent);
    switch (node->type) {
        case NODE_INT:
            printf("Int: %d\n", node->ival);
            break;
        case NODE_ID:
            printf("Id: %s\n", node->sval);
            break;
        case NODE_BINOP:
            printf("Op: %s\n", node->binop.op);
            print_ast(node->binop.left, indent + 1);
            print_ast(node->binop.right, indent + 1);
            break;
        case NODE_ASSIGN:
            printf("Asignación: %s =\n", node->assign.id);
            print_ast(node->assign.value, indent + 1);
            break;
        case NODE_PRINT:
            printf("Print:\n");
            print_ast(node->assign.value, indent + 1);
            break;
        case NODE_DECL:
            printf("Declaración (%s): %s\n",
                   node->decl.decl_type == NODE_INT ? "int" :
                   node->decl.decl_type == NODE_FLOAT ? "float" : "string",
                   node->decl.id);
            break;
        case NODE_IF:
            printf("If:\n");
            print_indent(indent + 1); printf("Condición:\n");
            print_ast(node->ifstmt.cond, indent + 2);
            print_indent(indent + 1); printf("Then:\n");
            print_ast(node->ifstmt.then_branch, indent + 2);
            if (node->ifstmt.else_branch) {
                print_indent(indent + 1); printf("Else:\n");
                print_ast(node->ifstmt.else_branch, indent + 2);
            }
            break;
        case NODE_WHILE:
            printf("While:\n");
            print_indent(indent + 1); printf("Condición:\n");
            print_ast(node->whilestmt.cond, indent + 2);
            print_indent(indent + 1); printf("Cuerpo:\n");
            print_ast(node->whilestmt.body, indent + 2);
            break;
        case NODE_BLOCK:
            printf("Bloque:\n");
            for (int i = 0; i < node->block.stmt_count; i++) {
                print_ast(node->block.stmts[i], indent + 1);
            }
            break;
        default:
            printf("Nodo desconocido\n");
            break;
    }
}
