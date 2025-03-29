import { MigrationInterface, QueryRunner } from "typeorm";

export class InitialSchema1711650000000 implements MigrationInterface {
    name = 'InitialSchema1711650000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create properties table
        await queryRunner.query(`
            CREATE TABLE "properties" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
                "yieldPlanetPropertyId" varchar NOT NULL,
                "name" varchar NOT NULL,
                "description" varchar,
                "address" varchar NOT NULL,
                "city" varchar NOT NULL,
                "country" varchar NOT NULL,
                "postalCode" varchar,
                "amenities" jsonb,
                "roomTypes" jsonb NOT NULL,
                "policies" jsonb,
                "isActive" boolean NOT NULL DEFAULT true,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
            )
        `);

        // Create reservations table
        await queryRunner.query(`
            CREATE TABLE "reservations" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
                "propertyId" varchar NOT NULL,
                "roomTypeId" varchar NOT NULL,
                "guestName" varchar NOT NULL,
                "guestEmail" varchar NOT NULL,
                "checkIn" TIMESTAMP NOT NULL,
                "checkOut" TIMESTAMP NOT NULL,
                "adults" integer NOT NULL,
                "children" integer,
                "totalPrice" decimal(10,2) NOT NULL,
                "currency" varchar NOT NULL,
                "additionalDetails" jsonb,
                "status" varchar NOT NULL DEFAULT 'pending',
                "yieldPlanetReservationId" varchar,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
            )
        `);

        // Create request_logs table
        await queryRunner.query(`
            CREATE TABLE "request_logs" (
                "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
                "service" varchar NOT NULL,
                "endpoint" varchar NOT NULL,
                "method" varchar NOT NULL,
                "requestHeaders" jsonb,
                "requestBody" jsonb,
                "responseHeaders" jsonb,
                "responseBody" jsonb,
                "statusCode" integer NOT NULL,
                "duration" integer NOT NULL,
                "error" varchar,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now()
            )
        `);

        // Create indexes
        await queryRunner.query(`CREATE INDEX "IDX_properties_yieldPlanetId" ON "properties"("yieldPlanetPropertyId")`);
        await queryRunner.query(`CREATE INDEX "IDX_reservations_propertyId" ON "reservations"("propertyId")`);
        await queryRunner.query(`CREATE INDEX "IDX_reservations_status" ON "reservations"("status")`);
        await queryRunner.query(`CREATE INDEX "IDX_request_logs_service" ON "request_logs"("service")`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop indexes
        await queryRunner.query(`DROP INDEX "IDX_request_logs_service"`);
        await queryRunner.query(`DROP INDEX "IDX_reservations_status"`);
        await queryRunner.query(`DROP INDEX "IDX_reservations_propertyId"`);
        await queryRunner.query(`DROP INDEX "IDX_properties_yieldPlanetId"`);

        // Drop tables
        await queryRunner.query(`DROP TABLE "request_logs"`);
        await queryRunner.query(`DROP TABLE "reservations"`);
        await queryRunner.query(`DROP TABLE "properties"`);
    }
} 