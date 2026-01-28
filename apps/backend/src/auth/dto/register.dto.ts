import { IsEmail, IsInt, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  name: string;

  @IsInt()
  departmentId: number;

  @IsInt()
  roleId: number;
}
