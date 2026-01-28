import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { HealthController } from './health/health.controller';
import { PrismaService } from './prisma/prisma.service';
import { RedisModule } from './redis/redis.module';

@Module({
  imports: [AuthModule, RedisModule],
  controllers: [HealthController],
  providers: [PrismaService],
})
export class AppModule {}
