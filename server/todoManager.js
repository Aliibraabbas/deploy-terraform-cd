import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  GetCommand,
  PutCommand,
  UpdateCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({
  region: process.env.AWS_REGION || "eu-west-1",
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || "fake",
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || "fake",
  },
});

const dynamo = DynamoDBDocumentClient.from(client);
const TABLE = process.env.DYNAMODB_TABLE_NAME || "cloud-devops-app-todos";

export class TodoManager {
  async getAll() {
    const result = await dynamo.send(new ScanCommand({ TableName: TABLE }));
    return result.Items || [];
  }

  async getById(id) {
    const result = await dynamo.send(
      new GetCommand({ TableName: TABLE, Key: { id } })
    );
    return result.Item || null;
  }

  async create(text) {
    const todo = {
      id: Date.now().toString(),
      text: text.trim(),
      completed: false,
      createdAt: new Date().toISOString(),
    };
    await dynamo.send(new PutCommand({ TableName: TABLE, Item: todo }));
    return todo;
  }

  async update(id, updates) {
    const expression = [];
    const values = {};
    if (updates.text) {
      expression.push("#text = :text");
      values[":text"] = updates.text.trim();
    }
    if (typeof updates.completed === "boolean") {
      expression.push("completed = :completed");
      values[":completed"] = updates.completed;
    }
    values[":updatedAt"] = new Date().toISOString();
    expression.push("updatedAt = :updatedAt");

    const result = await dynamo.send(
      new UpdateCommand({
        TableName: TABLE,
        Key: { id },
        UpdateExpression: "SET " + expression.join(", "),
        ExpressionAttributeValues: values,
        ExpressionAttributeNames: {
          "#text": "text",
        },
        ReturnValues: "ALL_NEW",
      })
    );

    return result.Attributes;
  }

  async delete(id) {
    const result = await dynamo.send(
      new DeleteCommand({
        TableName: TABLE,
        Key: { id },
        ReturnValues: "ALL_OLD",
      })
    );
    return result.Attributes;
  }
}
