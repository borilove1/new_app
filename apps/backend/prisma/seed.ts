import bcrypt from 'bcrypt';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const department = await prisma.department.create({
    data: { name: '기획팀' },
  });

  const seniorRole = await prisma.role.create({
    data: { title: '팀장', rankLevel: 2 },
  });

  const juniorRole = await prisma.role.create({
    data: { title: '사원', rankLevel: 1 },
  });

  const hashed = await bcrypt.hash('password123', 10);

  await prisma.user.create({
    data: {
      email: 'leader@company.com',
      passwordHash: hashed,
      name: '리더',
      departmentId: department.id,
      roleId: seniorRole.id,
    },
  });

  await prisma.user.create({
    data: {
      email: 'member@company.com',
      passwordHash: hashed,
      name: '멤버',
      departmentId: department.id,
      roleId: juniorRole.id,
    },
  });
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
