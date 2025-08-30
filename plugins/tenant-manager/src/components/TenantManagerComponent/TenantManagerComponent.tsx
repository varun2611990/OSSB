import React, { useState, useEffect } from 'react';
import {
  Typography,
  Grid,
  Card,
  CardContent,
  CardHeader,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Box,
  IconButton,
} from '@material-ui/core';
import {
  InfoCard,
  Header,
  Page,
  Content,
  ContentHeader,
  HeaderLabel,
  SupportButton,
} from '@backstage/core-components';
import { makeStyles } from '@material-ui/core/styles';
import EditIcon from '@material-ui/icons/Edit';
import AddIcon from '@material-ui/icons/Add';
import DeleteIcon from '@material-ui/icons/Delete';
import BusinessIcon from '@material-ui/icons/Business';
import PeopleIcon from '@material-ui/icons/People';
import StorageIcon from '@material-ui/icons/Storage';
import CloudIcon from '@material-ui/icons/Cloud';

const useStyles = makeStyles((theme) => ({
  summaryCard: {
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
  },
  summaryIcon: {
    fontSize: '3rem',
    color: theme.palette.primary.main,
    marginBottom: theme.spacing(2),
  },
  summaryValue: {
    fontSize: '2.5rem',
    fontWeight: 'bold',
    color: theme.palette.text.primary,
  },
  statusChip: {
    fontWeight: 'bold',
  },
  actionButton: {
    marginLeft: theme.spacing(1),
  },
  dialogForm: {
    display: 'flex',
    flexDirection: 'column',
    gap: theme.spacing(2),
    minWidth: '400px',
  },
}));

interface Tenant {
  id: string;
  name: string;
  subdomain: string;
  plan: 'starter' | 'professional' | 'enterprise';
  status: 'active' | 'suspended' | 'trial';
  userCount: number;
  projectCount: number;
  createdAt: string;
  lastActivity: string;
}

const mockTenants: Tenant[] = [
  {
    id: '1',
    name: 'Acme Corporation',
    subdomain: 'acme',
    plan: 'enterprise',
    status: 'active',
    userCount: 125,
    projectCount: 45,
    createdAt: '2024-01-15',
    lastActivity: '2024-12-01',
  },
  {
    id: '2',
    name: 'Tech Startup Inc',
    subdomain: 'techstartup',
    plan: 'professional',
    status: 'active',
    userCount: 25,
    projectCount: 12,
    createdAt: '2024-03-20',
    lastActivity: '2024-11-28',
  },
  {
    id: '3',
    name: 'Demo Company',
    subdomain: 'demo',
    plan: 'starter',
    status: 'trial',
    userCount: 5,
    projectCount: 3,
    createdAt: '2024-11-15',
    lastActivity: '2024-11-30',
  },
];

export const TenantManagerComponent = () => {
  const classes = useStyles();
  const [tenants, setTenants] = useState<Tenant[]>(mockTenants);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [selectedTenant, setSelectedTenant] = useState<Tenant | null>(null);
  const [newTenantDialogOpen, setNewTenantDialogOpen] = useState(false);

  const totalTenants = tenants.length;
  const activeTenants = tenants.filter(t => t.status === 'active').length;
  const totalUsers = tenants.reduce((sum, t) => sum + t.userCount, 0);
  const totalProjects = tenants.reduce((sum, t) => sum + t.projectCount, 0);

  const handleEditTenant = (tenant: Tenant) => {
    setSelectedTenant(tenant);
    setEditDialogOpen(true);
  };

  const handleSaveTenant = () => {
    if (selectedTenant) {
      setTenants(prev => 
        prev.map(t => t.id === selectedTenant.id ? selectedTenant : t)
      );
    }
    setEditDialogOpen(false);
    setSelectedTenant(null);
  };

  const handleCreateTenant = () => {
    setNewTenantDialogOpen(true);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'primary';
      case 'trial':
        return 'secondary';
      case 'suspended':
        return 'default';
      default:
        return 'default';
    }
  };

  const getPlanColor = (plan: string) => {
    switch (plan) {
      case 'enterprise':
        return 'primary';
      case 'professional':
        return 'secondary';
      case 'starter':
        return 'default';
      default:
        return 'default';
    }
  };

  return (
    <Page themeId="tool">
      <Header title="Tenant Management" subtitle="Manage multi-tenant organizations">
        <HeaderLabel label="Owner" value="Platform Team" />
        <HeaderLabel label="Lifecycle" value="Production" />
      </Header>
      <Content>
        <ContentHeader title="Organization Overview">
          <Button
            variant="contained"
            color="primary"
            startIcon={<AddIcon />}
            onClick={handleCreateTenant}
          >
            Create Tenant
          </Button>
          <SupportButton>
            Manage tenant organizations, users, and billing plans for the platform.
          </SupportButton>
        </ContentHeader>

        {/* Summary Cards */}
        <Grid container spacing={3} style={{ marginBottom: '2rem' }}>
          <Grid item xs={12} sm={6} md={3}>
            <Card className={classes.summaryCard}>
              <CardContent style={{ textAlign: 'center' }}>
                <BusinessIcon className={classes.summaryIcon} />
                <Typography variant="h6" color="textSecondary">
                  Total Tenants
                </Typography>
                <Typography className={classes.summaryValue}>
                  {totalTenants}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card className={classes.summaryCard}>
              <CardContent style={{ textAlign: 'center' }}>
                <CloudIcon className={classes.summaryIcon} />
                <Typography variant="h6" color="textSecondary">
                  Active Tenants
                </Typography>
                <Typography className={classes.summaryValue}>
                  {activeTenants}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card className={classes.summaryCard}>
              <CardContent style={{ textAlign: 'center' }}>
                <PeopleIcon className={classes.summaryIcon} />
                <Typography variant="h6" color="textSecondary">
                  Total Users
                </Typography>
                <Typography className={classes.summaryValue}>
                  {totalUsers}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card className={classes.summaryCard}>
              <CardContent style={{ textAlign: 'center' }}>
                <StorageIcon className={classes.summaryIcon} />
                <Typography variant="h6" color="textSecondary">
                  Total Projects
                </Typography>
                <Typography className={classes.summaryValue}>
                  {totalProjects}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Tenants Table */}
        <InfoCard title="Tenant Organizations">
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Organization</TableCell>
                  <TableCell>Subdomain</TableCell>
                  <TableCell>Plan</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell align="center">Users</TableCell>
                  <TableCell align="center">Projects</TableCell>
                  <TableCell>Last Activity</TableCell>
                  <TableCell align="center">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {tenants.map((tenant) => (
                  <TableRow key={tenant.id}>
                    <TableCell>
                      <Typography variant="subtitle1" style={{ fontWeight: 'bold' }}>
                        {tenant.name}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="textSecondary">
                        {tenant.subdomain}.backstage-saas.com
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={tenant.plan}
                        color={getPlanColor(tenant.plan) as any}
                        className={classes.statusChip}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={tenant.status}
                        color={getStatusColor(tenant.status) as any}
                        className={classes.statusChip}
                        size="small"
                      />
                    </TableCell>
                    <TableCell align="center">{tenant.userCount}</TableCell>
                    <TableCell align="center">{tenant.projectCount}</TableCell>
                    <TableCell>{tenant.lastActivity}</TableCell>
                    <TableCell align="center">
                      <IconButton
                        size="small"
                        onClick={() => handleEditTenant(tenant)}
                        title="Edit Tenant"
                      >
                        <EditIcon />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </InfoCard>

        {/* Edit Tenant Dialog */}
        <Dialog open={editDialogOpen} onClose={() => setEditDialogOpen(false)}>
          <DialogTitle>Edit Tenant</DialogTitle>
          <DialogContent>
            {selectedTenant && (
              <Box className={classes.dialogForm}>
                <TextField
                  label="Organization Name"
                  value={selectedTenant.name}
                  onChange={(e) => setSelectedTenant({
                    ...selectedTenant,
                    name: e.target.value
                  })}
                  fullWidth
                />
                <TextField
                  label="Subdomain"
                  value={selectedTenant.subdomain}
                  onChange={(e) => setSelectedTenant({
                    ...selectedTenant,
                    subdomain: e.target.value
                  })}
                  fullWidth
                />
                <FormControl fullWidth>
                  <InputLabel>Plan</InputLabel>
                  <Select
                    value={selectedTenant.plan}
                    onChange={(e) => setSelectedTenant({
                      ...selectedTenant,
                      plan: e.target.value as any
                    })}
                  >
                    <MenuItem value="starter">Starter</MenuItem>
                    <MenuItem value="professional">Professional</MenuItem>
                    <MenuItem value="enterprise">Enterprise</MenuItem>
                  </Select>
                </FormControl>
                <FormControl fullWidth>
                  <InputLabel>Status</InputLabel>
                  <Select
                    value={selectedTenant.status}
                    onChange={(e) => setSelectedTenant({
                      ...selectedTenant,
                      status: e.target.value as any
                    })}
                  >
                    <MenuItem value="active">Active</MenuItem>
                    <MenuItem value="trial">Trial</MenuItem>
                    <MenuItem value="suspended">Suspended</MenuItem>
                  </Select>
                </FormControl>
              </Box>
            )}
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setEditDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleSaveTenant} variant="contained" color="primary">
              Save Changes
            </Button>
          </DialogActions>
        </Dialog>

        {/* Create Tenant Dialog */}
        <Dialog open={newTenantDialogOpen} onClose={() => setNewTenantDialogOpen(false)}>
          <DialogTitle>Create New Tenant</DialogTitle>
          <DialogContent>
            <Box className={classes.dialogForm}>
              <TextField
                label="Organization Name"
                placeholder="Acme Corporation"
                fullWidth
              />
              <TextField
                label="Subdomain"
                placeholder="acme"
                fullWidth
                helperText="Will be available at: [subdomain].backstage-saas.com"
              />
              <TextField
                label="Admin Email"
                placeholder="admin@acme.com"
                type="email"
                fullWidth
              />
              <FormControl fullWidth>
                <InputLabel>Initial Plan</InputLabel>
                <Select defaultValue="starter">
                  <MenuItem value="starter">Starter - $29/month</MenuItem>
                  <MenuItem value="professional">Professional - $99/month</MenuItem>
                  <MenuItem value="enterprise">Enterprise - $299/month</MenuItem>
                </Select>
              </FormControl>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setNewTenantDialogOpen(false)}>Cancel</Button>
            <Button variant="contained" color="primary">
              Create Tenant
            </Button>
          </DialogActions>
        </Dialog>
      </Content>
    </Page>
  );
};